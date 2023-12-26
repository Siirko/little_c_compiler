#include "../include/hashmap.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

hashmap_t *hashmap_init(int size)
{
    hashmap_t *map = calloc(sizeof(hashmap_t), 1);
    if (map == NULL)
        return NULL;
    map->size = size;
    map->count = 0;
    map->nodes = calloc(sizeof(hashnode_t *), size + 1);
    if (map->nodes == NULL)
        return NULL;
    return map;
}

void hashmap_free(hashmap_t *map)
{
    for (int i = 0; i < map->size; i++)
    {
        hashnode_t *node = map->nodes[i];
        while (node != NULL)
        {
            hashnode_t *next = node->next;
            free(node->key);
            free(node->value);
            free(node);
            node = next;
        }
    }
    free(map->nodes);
    map->size = 0;
    map->count = 0;
    map->nodes = NULL;
}

void hashmap_resize(hashmap_t *map, int size)
{
    hashmap_t *new_map = hashmap_init(size);
    for (int i = 0; i < map->size; i++)
    {
        hashnode_t *node = map->nodes[i];
        while (node != NULL)
        {
            if (node->deleted == 1)
                continue;
            hashmap_insert(new_map, node->key, node->value, node->value_size);
            node = node->next;
        }
    }
    hashmap_free(map);
    map->size = new_map->size;
    map->count = new_map->count;
    map->nodes = new_map->nodes;
    free(new_map);
}

int hashmap_insert(hashmap_t *map, char *key, void *value, size_t value_size)
{
    int index = djb2_hash(key) % map->size;
    hashnode_t *node = map->nodes[index];
    while (node != NULL)
    {
        if (strcmp(node->key, key) == 0)
        {
            node->deleted = 0;
            free(node->value);
            node->value = malloc(value_size);
            if (node->value == NULL)
                return 0;
            memcpy(node->value, value, value_size);
            node->value_size = value_size;
            return 1;
        }
        node = node->next;
    }
    node = calloc(sizeof(hashnode_t), 1);
    if (node == NULL)
    {
        printf("hashmap_insert: malloc failed");
        exit(EXIT_FAILURE);
    }
    node->key = strdup(key);
    if (node->key == NULL)
    {
        free(node);
        return 0;
    }
    node->value = malloc(value_size);
    if (node->value == NULL)
    {
        free(node->key);
        free(node);
        return 0;
    }
    memcpy(node->value, value, value_size);
    node->value_size = value_size;
    node->deleted = 0;
    node->next = map->nodes[index];
    map->nodes[index] = node;
    map->count++;
    if ((double)map->count / map->size > HASH_LOAD_FACTOR)
    {
        int size = map->size * 2;
        hashmap_resize(map, size);
    }
    return 1;
}

int hashmap_remove(hashmap_t *map, char *key)
{
    int index = djb2_hash(key) % map->size;
    hashnode_t *node = map->nodes[index];
    while (node != NULL)
    {
        if (strcmp(node->key, key) == 0)
        {
            node->deleted = 1;
            map->count--;
            return 1;
        }
        node = node->next;
    }
    return 0;
}

void *hashmap_get(hashmap_t *map, char *key)
{
    int index = djb2_hash(key) % map->size;
    hashnode_t *node = map->nodes[index];
    while (node != NULL)
    {
        if (strcmp(node->key, key) == 0 && !node->deleted)
            return node->value;
        node = node->next;
    }
    return NULL;
}

bool hashmap_contains(hashmap_t *map, char *key) { return hashmap_get(map, key) != NULL; }

size_t hashmap_count(hashmap_t *map) { return map->count; }

bool hashmap_is_empty(hashmap_t *map) { return map->count == 0; }

void hashmap_iterate(hashmap_t *map, void (*callback)(char *, void *))
{
    for (int i = 0; i < map->size; i++)
    {
        hashnode_t *node = map->nodes[i];
        while (node != NULL)
        {
            if (!node->deleted)
                callback(node->key, node->value);
            node = node->next;
        }
    }
}

void hashmap_iter_init(hashmap_iter_t *iter, hashmap_t *map)
{
    iter->map = map;
    iter->index = 0;
    iter->node = map->nodes[0];
    while (iter->node == NULL && iter->index < map->size)
    {
        iter->index++;
        iter->node = map->nodes[iter->index];
    }
}

int hashmap_iter_has_next(hashmap_iter_t *iter) { return iter->node != NULL; }

int hashmap_iter_next(hashmap_iter_t *iter)
{
    if (iter->node == NULL)
        return 0;
    iter->node = iter->node->next;
    while (iter->node == NULL && iter->index < iter->map->size)
    {
        iter->index++;
        iter->node = iter->map->nodes[iter->index];
    }
    return 1;
}

char *hashmap_iter_get_key(hashmap_iter_t *iter) { return iter->node->key; }

void *hashmap_iter_get_value(hashmap_iter_t *iter) { return iter->node->value; }

int cmp_hashnode_keys(const void *a, const void *b)
{
    hashnode_t *node_a = *(hashnode_t **)a;
    hashnode_t *node_b = *(hashnode_t **)b;
    int key_a = strtol(node_a->key, NULL, 10);
    int key_b = strtol(node_b->key, NULL, 10);
    if (key_b == 0 || key_a == 0)
    {
        return strcmp(node_a->key, node_b->key);
    }
    return (key_a < key_b) ? -1 : (key_a > key_b);
}

void hashmap_sort_keys(hashmap_t *map, int (*cmp)(const void *, const void *))
{
    hashnode_t **nodes = malloc(sizeof(hashnode_t *) * map->count);
    if (nodes == NULL)
    {
        printf("hashmap_sort_keys: malloc failed");
        exit(EXIT_FAILURE);
    }
    int index = 0;
    for (int i = 0; i < map->size; i++)
    {
        hashnode_t *node = map->nodes[i];
        while (node != NULL)
        {
            if (!node->deleted)
                nodes[index++] = node;
            node = node->next;
        }
    }
    qsort(nodes, map->count, sizeof(hashnode_t *), cmp);
    hashnode_t **new_nodes = calloc(sizeof(hashnode_t *), map->size + 1);
    if (new_nodes == NULL)
    {
        printf("hashmap_sort_keys: calloc failed");
        exit(EXIT_FAILURE);
    }
    for (int i = 0; i < map->count; i++)
    {
        nodes[i]->next = new_nodes[i % map->size];
        new_nodes[i % map->size] = nodes[i];
    }
    free(map->nodes);
    map->nodes = new_nodes;
    free(nodes);
}

// https://theartincode.stanis.me/008-djb2/

uint32_t djb2_hash(char *str)
{
    unsigned long hash = 5381;
    int c;
    while ((c = *str++))
        hash = ((hash << 5) + hash) + c;
    return hash;
}

uint32_t murmur3_32(const uint8_t *key, size_t len, uint32_t seed)
{
    uint32_t h = seed;
    if (len > 3)
    {
        size_t i = len >> 2;
        do
        {
            uint32_t k;
            memcpy(&k, key, sizeof(uint32_t));
            key += sizeof(uint32_t);
            k *= 0xcc9e2d51;
            k = (k << 15) | (k >> 17);
            k *= 0x1b873593;
            h ^= k;
            h = (h << 13) | (h >> 19);
            h = h * 5 + 0xe6546b64;
        } while (--i);
    }
    if (len & 3)
    {
        size_t i = len & 3;
        uint32_t k = 0;
        do
        {
            k <<= 8;
            k |= key[i - 1];
        } while (--i);
        k *= 0xcc9e2d51;
        k = (k << 15) | (k >> 17);
        k *= 0x1b873593;
        h ^= k;
    }
    h ^= len;
    h ^= h >> 16;
    h *= 0x85ebca6b;
    h ^= h >> 13;
    h *= 0xc2b2ae35;
    h ^= h >> 16;
    return h;
}
