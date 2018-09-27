/*
 * spi_thread.c
 *
 *  Created on: 03.09.2018
 *      Author: caput
 */
#include "spi_thread.h"
#include "stdbool.h"

static XSpiPs spi;

void InitSPI(void)
{
	u8 data[2] = {0xcd, 0x8a};
	u8 received[2] = {0};
	XSpiPs_Config* config = XSpiPs_LookupConfig(0);
	XSpiPs_CfgInitialize(&spi, config, config->BaseAddress);
	XSpiPs_SetOptions(&spi, 0x0002FC0F);
	XSpiPs_SetClkPrescaler(&spi,7);
	volatile bool x = XSpiPs_IsManualStart(&spi);
	x = XSpiPs_IsMaster(&spi);
	x = XSpiPs_IsManualStart(&spi);

}

XSpiPs* GetSPIHandle(void)
{
	return &spi;
}

