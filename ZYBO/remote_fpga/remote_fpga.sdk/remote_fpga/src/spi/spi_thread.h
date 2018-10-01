/*
 * spi_thread.h
 *
 *  Created on: 03.09.2018
 *      Author: caput
 */

#ifndef __SPI_THREAD_H_
#define __SPI_THREAD_H_

#include "xspips.h"

void InitSPI(void);
XSpiPs* GetSPIHandle(void);
void start_spi_thread(void);

#endif /* __SPI_THREAD_H_ */
