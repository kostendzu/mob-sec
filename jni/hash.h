#ifndef HASH_H
#define HASH_H

#include <stdint.h>

void calculateHash(const uint8_t* message, size_t messageLength, uint8_t* hashBuffer);

#endif  // HASH_H
