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
	XSpiPs_Config* config = XSpiPs_LookupConfig(0);
	XSpiPs_CfgInitialize(&spi, config, config->BaseAddress);
	XSpiPs_SetOptions(&spi, 0x0002FC0F);
	XSpiPs_SetClkPrescaler(&spi,4);
}

XSpiPs* GetSPIHandle(void)
{
	return &spi;
}

void spi_thread(void *p)
{
	volatile u8 x;
	while(1)
	{

	}
}

void start_spi_thread(void)
{
	InitSPI();

}
