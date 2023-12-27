#pragma once

#include "vec.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HASH_LOAD_FACTOR 0.75

typedef struct hashnode_t
{
    char *key;
    void *value;
    size_t value_size;
    int deleted;
    struct hashnode_t *next;
} hashnode_t;

typedef struct
{
    size_t size;
    int count;
    hashnode_t **nodes;
} hashmap_t;
typedef vec_t(hashmap_t *) vec_hashmap_t;
typedef vec_t(vec_hashmap_t) vec_vec_hashmap_t;

typedef struct
{
    hashmap_t *map;
    int index;
    hashnode_t *node;
} hashmap_iter_t;

/**
 * @brief Hash function following the djb2 algorithm
 * @param str The string to hash
 * @return The hash
 */
uint32_t djb2_hash(char *str);

uint32_t murmur3_32(const uint8_t *key, size_t len, uint32_t seed);

/**
 * @brief Initialize the hashmap
 * @param size The size of the hashmap
 * @return The hashmap
 */
hashmap_t *hashmap_init(int size);

/**
 * @brief Free the hashmap
 */
void hashmap_free(hashmap_t *map);

/**
 * @brief Resize the hashmap
 * @param map The hashmap
 * @param size The new size
 */
void hashmap_resize(hashmap_t *map, int size);

/**
 * @brief Insert a value in the hashmap according to a key and a value_size
 * @param map The hashmap
 * @param key The key
 * @param value The value
 * @param value_size The size of the value
 * @return 0 if the insertion is successful, 1 otherwise
 */
int hashmap_insert(hashmap_t *map, char *key, void *value, size_t value_size);

/**
 * @brief Remove a value from the hashmap
 * @param map The hashmap
 * @param key The key
 * @return 0 if the removal is successful, 1 otherwise
 */
int hashmap_remove(hashmap_t *map, char *key);

/**
 * @brief Get a value from the hashmap
 * @param map The hashmap
 * @param key The key
 * @return The value
 * @note Returns NULL if the key is not found
 */
void *hashmap_get(hashmap_t *map, char *key);

/**
 * @brief Tell if the hashmap contains a key
 * @param map The hashmap
 * @param key
 * @return true if the key is found, false otherwise
 */
bool hashmap_contains(hashmap_t *map, char *key);

/**
 * @brief Get the number of elements in the hashmap
 * @param map The hashmap
 * @return The number of elements
 */
size_t hashmap_count(hashmap_t *map);

/**
 * @brief Tell if the hashmap is empty
 * @param map The hashmap
 * @return true if the hashmap is empty, false otherwise
 */
bool hashmap_is_empty(hashmap_t *map);

/**
 * @brief Iterate over the hashmap
 * @param map The hashmap
 * @param callback The callback function
 */
void hashmap_iterate(hashmap_t *map, void (*callback)(char *, void *));

/**
 * @brief Initialize the hashmap iterator
 * @param iter The hashmap iterator
 * @param map The hashmap
 */
void hashmap_iter_init(hashmap_iter_t *iter, hashmap_t *map);

/**
 * @brief Get the next node
 * @param iter The hashmap iterator
 * @return The next node
 */
int hashmap_iter_has_next(hashmap_iter_t *iter);

/**
 * @brief Get the next node
 * @param iter The hashmap iterator
 * @return The next node
 */
int hashmap_iter_next(hashmap_iter_t *iter);

/**
 * @brief Get the key of the current node
 * @param iter The hashmap iterator
 * @return The key
 */
char *hashmap_iter_get_key(hashmap_iter_t *iter);

/**
 * @brief Get the value of the current node
 * @param iter The hashmap iterator
 * @return The value
 */
void *hashmap_iter_get_value(hashmap_iter_t *iter);

/**
 * @brief Compare two hashnodes according to their keys
 * @param a The first hashnode
 * @param b The second hashnode
 * @return 0 if the keys are equal, 1 if the first key is greater than the second key, -1 otherwise
 */
int cmp_hashnode_keys(const void *a, const void *b);

/**
 * @brief Sort the hashmap according to the keys
 * @param map The hashmap
 */
void hashmap_sort_keys(hashmap_t *map, int (*cmp)(const void *, const void *));