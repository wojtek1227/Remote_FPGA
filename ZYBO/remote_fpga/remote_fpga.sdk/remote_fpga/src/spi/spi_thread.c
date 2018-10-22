/*
 * spi_thread.c
 *
 *  Created on: 03.09.2018
 *      Author: caput
 */
#include "spi_thread.h"
#include "stdbool.h"
#include "grabber_registers_addr.h"
#include "FreeRTOS.h"
#include "queue.h"

#define SPI_THREAD_STACKSIZE 1024
static XSpiPs spi;
static u8 leds_and_display_data[RO_MEM_ADDR_END - RO_MEM_ADDR_START] = {0};

QueueHandle_t spi_queue;

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

void spi_read_all_outputs(void)
{
	u8 write_buffer[3];
	u8 read_buffer[3];
	write_buffer[0] = READ;
	write_buffer[1] = RO_MEM_ADDR_START;
	write_buffer[3] = 0;
	for(u8 i = 0; i < sizeof(leds_and_display_data); i++)
	{
		XSpiPs_PolledTransfer(&spi, &write_buffer + i, &read_buffer, 3);
		leds_and_display_data[i] = read_buffer[3];

	}
}

void spi_thread(void *p)
{
	volatile u8 x;
	xil_printf("Start spi thread\r\n");
	u8 command[3];
	InitSPI();
	while(1)
	{

		x++;
		xil_printf("Spi is alive\r\n");
		xQueueReceive(spi_queue, command, 0);
		xil_printf("Command %02X %02X %02X\r\n", command[0], command[1], command[2]);
		vTaskDelay(1000/portTICK_PERIOD_MS);
	}
}

void start_spi_thread(void *p)
{
	sys_thread_new("SPI thread", spi_thread, (void *)p, SPI_THREAD_STACKSIZE);

}
