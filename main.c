 // Lab3P1.c
 //
 // Created: 1/30/2018 4:04:52 AM
 // Author : Eugene Rockey
 // Copyright 2018, All Rights Reserved

#include <math.h>
#include <stdio.h>
#include <time.h>
 


 
 const char MS1[] = "\r\nECE-412 ATMega328P Tiny OS";
 const char MS2[] = "\r\nby Eugene Rockey Copyright 2018, All Rights Reserved";
 const char MS3[] = "\r\nMenu: (L)CD, (A)CD, (E)EPROM, (U)USART\r\n";
 const char MS4[] = "\r\nReady: ";
 const char MS5[] = "\r\nInvalid Command Try Again...";
 const char MS6[] = "Volts\r";

 const char MS7[] = " F\r";
 char output[] = "Group 1 is #1                Group 1 is #1                Group 1 is #1";

 int keyStroke = 0;
 

void LCD_Init(void);			//external Assembly functions
void UART_Init(void);
void UART_Clear(void);
void UART_Get(void);
void UART_Put(void);
void LCD_Write_Data(void);
void LCD_Write_Command(void);
void LCD_Read_Data(void);
void LCD_Delay(void);
void Mega328P_Init(void);
void ADC_Get(void);
void EEPROM_Read(void);
void EEPROM_Write(void);
void SETB(void);
void SETC(void);
void CLEARB(void);
void CLEARC(void);
void SETBAUD(void);

int EELOCH;						//memory location for EEPROM storing High and Low
int EELOCL;

int BAUDH;						
int BAUDL;
int USARTDATA;					//used to set or clear bits in UCSR0B or UCSR0C

unsigned char ASCII;			//shared I/O variable with Assembly
unsigned char DATA;				//shared internal variable with Assembly
char HADC;						//shared ADC variable with Assembly
char LADC;						//shared ADC variable with Assembly

char volts[6];					//string buffer for ADC output
int Acc;						//Accumulator for ADC use

void UART_Puts(const char *str)	//Display a string in the PC Terminal Program
{
	while (*str)
	{
		ASCII = *str++;
		UART_Put();
	}
}

void LCD_Puts(const char *str)	//Display a string on the LCD Module
{
	while (*str)
	{
		DATA = *str++;
		LCD_Write_Data();
	}
}


void Banner(void)				//Display Tiny OS Banner on Terminal
{
	UART_Puts(MS1);
	UART_Puts(MS2);
	UART_Puts(MS4);
}

void HELP(void)						//Display available Tiny OS Commands on Terminal
{
	UART_Puts(MS3);
}



void LCD(void)						//Lite LCD demo
{

	int FLAG = 0;
	int i = 0;

	LCD_Write_Command();
	DATA = 0x08;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x02;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x06;					//Student Comment Here
	LCD_Write_Command();
	DATA = 0x0f;					//Student Comment Here
	LCD_Write_Command();
	LCD_Puts(output);

	for (i = 0; i < 16; i++){
		DATA = 0x1c;
		for (int j = 0; j < 50; j++)
		{
			LCD_Delay();
			
		}
		UART_Puts("test\r\n");
		if (FLAG)
		{
			break;
		}
		LCD_Write_Command();
	} 


	
	/*
	Re-engineer this subroutine to have the LCD endlessly scroll a marquee sign of 
	your Team's name either vertically or horizontally. Any key press should stop
	the scrolling and return execution to the command line in Terminal. User must
	always be able to return to command line.
	*/
}

void ADC(void)						//Lite Demo of the Analog to Digital Converter
{
	double r, t;
	int rn = 10000;
	volts[0x2]='.';
	volts[0x4]=' ';
	volts[0x5]= 0;
	
	ADC_Get();
	Acc = (((int)HADC)*0x100+(int)(LADC));
	
	r = (10000.0 * Acc) / (1040.0 - Acc);
	
	t = (3950*298.15)/(298.15*log(r/rn) + 3950);
	
	t = t - 273.15;						//Convert to C from K
	
	t = t*(9/5) + 32;					//Convert to F from C

    int i = t*10; 
	int j = t;
	volts[0x0] = i / 100 + 48;
	
	volts[0x1] = j % 10 + 48;
	
	volts[0x3] = i % 10 + 48;

	
	UART_Puts(volts);
	UART_Puts(MS7);

	/*
		Re-engineer this subroutine to display temperature in degrees Fahrenheit on the Terminal.
		The potentiometer simulates a thermistor, its varying resistance simulates the
		varying resistance of a thermistor as it is heated and cooled. See the thermistor
		equations in the lab 3 folder. User must always be able to return to command line.
	*/
	
}

void EEPROM(void)
{
	char eeGet[] = "0x####";
	UART_Puts("\r\nEEPROM Write and Read.");
	/*
	Re-engineer this subroutine so that a byte of data can be written to any address in EEPROM
	during run-time via the command line and the same byte of data can be read back and verified after the power to
	the Xplained Mini board has been cycled. Ask the user to enter a valid EEPROM address and an
	8-bit data value. Utilize the following two given Assembly based drivers to communicate with the EEPROM. You
	may modify the EEPROM drivers as needed. User must be able to always return to command line.
	*/
	UART_Puts("\r\ninput memory location in this format: 0x####");

	for (int i = 0; i < 6; i++){
		ASCII = '\0';
		while (ASCII == '\0'){
			UART_Get();
			}
		eeGet[i] = ASCII;
		UART_Puts(eeGet[i]);
	}
	EELOCH = (eeGet[2] - 48) + (eeGet[3] - 48);
	EELOCL = (eeGet[4] - 48) + (eeGet[5] - 48);
	UART_Puts("\r\n");
	EEPROM_Write();
	UART_Puts("\r\n");
	EEPROM_Read();
	UART_Put();
	UART_Puts("\r\n");
}

void BAUD(void)
{
	UART_Puts("\r\nBaud rater\n(1)9600\r\n(2)2400\r\n(3)1200\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case '1':
		BAUDH = 0;
		BAUDL = 103;
		SETBAUD();
		break;
		case '2':
		BAUDH = 1;
		BAUDL = 159;
		SETBAUD();
		break;
		case '3':
		BAUDH = 3;
		BAUDL = 63;
		SETBAUD();
		break;
		default:
		UART_Puts("\r\nIncorrect input\r\n");
		break;
	}

}

void DATAb(void)
{
	UART_Puts("\r\n# of Data Bits\r\n(1)5-bits\r\n(2)6-bits\r\n(3)7-bits\r\n(4)8-bits\r\n(5)9-bits\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case '1':
		USARTDATA = 6;
		CLEARC();
		USARTDATA = 4;
		CLEARB();
		break;
		case '2':
		USARTDATA = 4;
		CLEARC();
		USARTDATA = 2;
		SETC();
		USARTDATA = 4;
		CLEARB();
		break;
		case '3':
		USARTDATA = 4;
		SETC();
		USARTDATA = 2;
		CLEARC();
		USARTDATA = 4;
		CLEARB();
		break;
		case '4':
		USARTDATA = 6;
		SETC();
		USARTDATA = 4;
		CLEARB();
		break;
		case '5':
		USARTDATA = 6;
		SETC();
		USARTDATA = 4;
		SETB();
		break;
		default:
		UART_Puts("\r\nIncorrect input\r\n");
		break;
	}
}

void PARITY(void)
{
	UART_Puts("\r\nParity\r\n(1)even\r\n(2)odd\r\n(3)none\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case '1':
		USARTDATA = 48;
		CLEARC();
		break;
		case '2':
		USARTDATA = 32;
		SETC();
		USARTDATA = 16;
		CLEARC();
		break;
		case '3':
		USARTDATA = 48;
		SETC();
		break;
		default:
		UART_Puts("\r\nIncorrect input\r\n");
		break;
	}
}

void STOPb(void)
{
	USARTDATA = 8;
	UART_Puts("\r\n# of Stop bits\r\n(1)1-bit\r\n(2)2-bits\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case '1': CLEARC();
		break;
		case '2': SETC();
		break;
		default:
		UART_Puts("\r\nIncorrect input\r\n");
		break;
	}
}

void USART(void)
{
	UART_Puts("\r\nUSART Config\r\n(1)Baud Rate\r\n(2)# of Data bits\r\n(3)Parity\r\n(4)# of Stop Bits\r\n");
	ASCII = '\0';
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case '1': BAUD();
		break;
		case '2': DATAb();
		break;
		case '3': PARITY();
		break;
		case '4': STOPb();
		break;
		default:
		UART_Puts("\r\nIncorrect input\r\n");
		break;
	}
}

void Command(void)					//command interpreter
{
	UART_Puts(MS3);
	ASCII = '\0';						
	while (ASCII == '\0')
	{
		UART_Get();
	}
	switch (ASCII)
	{
		case 'L' | 'l': LCD();
		break;
		case 'A' | 'a': ADC();
		break;
		case 'E' | 'e': EEPROM();
		break;
		case 'U' | 'u': USART();
		break;
		default:
		UART_Puts(MS5);
		HELP();
		break;  			//Add a 'USART' command and subroutine to allow the user to reconfigure the 						//serial port parameters during runtime. Modify baud rate, # of data bits, parity, 							//# of stop bits.
	}
}

int main(void)
{
	Mega328P_Init();
	Banner();
	while (1)
	{
		Command();				//infinite command loop
	}
}

