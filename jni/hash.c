#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/sha.h>

// Функция для расчета хэша сообщения
void calculateHash(const uint8_t* message, size_t messageLength, uint8_t* hashBuffer) {
  SHA256_CTX ctx;
  SHA256_Init(&ctx);
  SHA256_Update(&ctx, message, messageLength);
  SHA256_Final(hashBuffer, &ctx);
  //memset(hashBuffer, 0, 32);
}
