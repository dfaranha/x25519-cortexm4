#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PART_TM4C123GH6PM
#include "inc/hw_gpio.h"
#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_uart.h"
#include "inc/hw_types.h"
#include "driverlib/rom.h"
#include "driverlib/rom_map.h"
#include "driverlib/uart.h"
#include "driverlib/sysctl.h"
#include "driverlib/pin_map.h"
#include "driverlib/gpio.h"
#include "driverlib/cpu.h"

#include "scalarmult.ih"

extern int measuretiming(unsigned char *q, unsigned char const *n, unsigned char const *p);

void initUART(){
	SysCtlPeripheralEnable(SYSCTL_PERIPH_UART1);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOB);
	
	GPIOPinConfigure(GPIO_PB0_U1RX);
	GPIOPinConfigure(GPIO_PB1_U1TX);
	GPIOPinTypeUART(GPIO_PORTB_BASE, GPIO_PIN_0 | GPIO_PIN_1);
	
	UARTConfigSetExpClk(UART1_BASE, SysCtlClockGet(), 230400, UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE | UART_CONFIG_PAR_NONE);
}

void send_val(unsigned char const *val)
{
	for (int idx = 0; idx < 32; ++idx) {
		while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_TXFF);
		HWREG(UART1_BASE + UART_O_DR) = val[idx];
	}
}

void read_val(unsigned char *val)
{
	for (int idx = 0; idx < 32; ++idx) {
		while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_RXFE);
		val[idx] = (unsigned char)HWREG(UART1_BASE + UART_O_DR);
	}
}

void send_int(int val)
{
	while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_TXFF);
	HWREG(UART1_BASE + UART_O_DR) = val & 0xFF;

	while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_TXFF);
	HWREG(UART1_BASE + UART_O_DR) = (val >> 8) & 0xFF;

	while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_TXFF);
	HWREG(UART1_BASE + UART_O_DR) = (val >> 16) & 0xFF;

	while(HWREG(UART1_BASE + UART_O_FR) & UART_FR_TXFF);
	HWREG(UART1_BASE + UART_O_DR) = val >> 24;
}

// Main currently setup to measure timing. Expect constant time behavior on M4,
// variable cycles on M3.
int main(void)
{
	unsigned char q[32], n[32], p[32];
	initUART();
	
	while(1)
	{
		read_val(n);
		read_val(p);
//		scalarmult(q, n, p);
		int cycles = measuretiming(q,n,p);
		send_val(q);
		send_int(cycles);
	}
}
