#include<stdint.h>
#include<stdlib.h>
#include<stdio.h>
#include<stdbool.h>


// set GPIOA pin 3 as output
/*
*(volatile uint32_t *) (0x50000000 + 0x00) &= ~(3 << 6); // clear bits 6 and 7
*(volatile uint32_t *) (0x50000000 + 0x00) |= (1 << 6); // set bit 6

// set GPIOB pin 5 as analog
*(volatile uint32_t *) (0x50000400 + 0x00) &= ~(3 << 10); //clear bits 10 and 11
*(volatile uint32_t *) (0x50000400 + 0x00) |= ~(3 << 10); //set bit 10 and 11

// set GPIOC pin 9 high
*(volatile uint32_t *) (0x50000800 + 0x14) |= (1 << 9); //set bit 9
*(volatile uint32_t *) (0x50000800 + 0x14) &= ~(1 << 9); //set bit 9
*/


struct gpio
{
	volatile uint32_t MODER, OTYPER, OSPEEDR, PUPDR, IDR, ODR, BSRR, LCKR, AFRL, AFRH, BRR;

};
/*
#define GPIOA((struct gpio*) (0x50000000 + 0x000))
#define GPIOB((struct gpio*) (0x50000000 + 0x400))
#define GPIOC((struct gpio*) (0x50000000 + 0x800))
*/

#define BIT(x) (1UL << x)
#define GPIO(bank) ((struct gpio * ) (0x50000000 + 0x400 * (bank)))
#define PIN(bank, num)((((bank) - 'A') << 8) | (num))
#define PINNO(pin) (pin & 0xFF)
#define PINBANK(pin) (pin >> 8)

enum {GPIO_INPUT_MODE, GPIO_OUTPUT_MODE, GPIO_AF_MODE, GPIO_ANALOG_MODE};

static inline void gpio_set_mode(uint16_t pin, uint8_t mode)
{
	struct gpio * gpio = GPIO(PINBANK(pin));
	uint8_t n = PINNO(pin);
	gpio->MODER &= ~(3U << (n * 2));	//clear bit
	gpio->MODER |= (mode & 3U) << (n * 2);	//set bit

}

struct rcc{
	volatile uint32_t CR, CFGR, CIR, APB2RSTR, APB1RSTR, AHBENR, APB2ENR, APB1ENR, BDCR, CSR, AHBRSTR,
			 			CFGR2, CFGR3; 
};

#define RCC ((struct rcc*) (0x40023800))

static inline void gpio_write(uint16_t pin, bool val){
	struct gpio * gpio = GPIO(PINBANK(pin));
	gpio->BSRR |= (1U << PINNO(pin)) << (val ? 0 : 16);
}

static inline void delay(volatile uint32_t counter){
	while(counter--)
		asm("nop");
}

int main(void)
{
	uint16_t led = PIN('B', 7);
	RCC->AHBENR |= BIT(PINBANK(led));
	gpio_set_mode(led, GPIO_OUTPUT_MODE);
	for(;;)
	{
		gpio_write(led, true);

		delay(100000);

		gpio_write(led, false);
	}
	return 0;
}



__attribute__((naked, noreturn)) void _reset(void){
	extern long _sbss, _ebss, _sdata, _edata, _sidata;
	for(long *dst = &_sbss; dst < &_ebss; dst++)
	{
		*dst = 0;
	}
	
	for(long *dst = &_sdata, *src = &_sidata; dst < &_edata;)
		*dst++ = *src;

	for(;;){
		(void)0;
	}	
}

extern void _estack(void);

__attribute__((section(".vectors"))) void(*const tab[16 + 91])(void) = {
	_estack, _reset
};


