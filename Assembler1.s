 // Lab3P1.s
 //
 // Created: 6/21/2018 4:15:16 AM
 // Author : Group 1
 // Copyright 2018, All Rights Reserved

 //Greg 
.section ".data"					//student comment here
.equ	DDRB,0x04					//student comment here
.equ	DDRD,0x0A					//student comment here
.equ	PORTB,0x05					//student comment here
.equ	PORTD,0x0B					//student comment here
.equ	U2X0,1						//student comment here
.equ	UBRR0L,0xC4					//student comment here
.equ	UBRR0H,0xC5					//student comment here
.equ	UCSR0A,0xC0					//student comment here
.equ	UCSR0B,0xC1					//student comment here
.equ	UCSR0C,0xC2					//student comment here
.equ	UDR0,0xC6					//student comment here
.equ	RXC0,0x07					//student comment here
.equ	UDRE0,0x05					//student comment here
.equ	ADCSRA,0x7A					//student comment here
.equ	ADMUX,0x7C					//student comment here
.equ	ADCSRB,0x7B					//student comment here
.equ	DIDR0,0x7E					//student comment here
.equ	DIDR1,0x7F					//student comment here
.equ	ADSC,6						//student comment here
.equ	ADIF,4						//student comment here
.equ	ADCL,0x78					//student comment here
.equ	ADCH,0x79					//student comment here
.equ	EECR,0x1F					//student comment here
.equ	EEDR,0x20					//student comment here
.equ	EEARL,0x21					//student comment here
.equ	EEARH,0x22					//student comment here
.equ	EERE,0						//student comment here
.equ	EEPE,1						//student comment here
.equ	EEMPE,2						//student comment here
.equ	EERIE,3						//student comment here
.equ	EELOCH,0
.equ	EELOCL,0

.global BAUDH				//high baud rate value
.global BAUDL				//low baud rate value
.global USARTDATA			// used to set or clear bits in UCSR0B and UCSR0C

.global HADC				//student comment here
.global LADC				//student comment here
.global ASCII				//student comment here
.global DATA				//student comment here

.set	temp,0				//student comment here

.section ".text"			//student comment here

//Mo
.global Mega328P_Init
Mega328P_Init:
		ldi	r16,0x07		;PB0(R*W),PB1(RS),PB2(E) as fixed outputs
		out	DDRB,r16		//store the data into DDRB to determine if pin B is ussed for input or output
		ldi	r16,0			//set the register back to 0
		out	PORTB,r16		//use the data in the register storing it in the address to port B
		out	U2X0,r16		;initialize UART, 8bits, no parity, 1 stop, 9600
		ldi	r17,0x0			//initialize register 17 with 0x0
		ldi	r16,0x67		//initialize register 16 with 0x67
		sts	UBRR0H,r17		//set baud rate for high
		sts	UBRR0L,r16		//set baud rate for low
		ldi	r16,24			//load 24 into register 16
		sts	UCSR0B,r16		//enable reciever and transistor 
		ldi	r16,6			//load 6 into r 16
		sts	UCSR0C,r16		//set frame rate based off register 16
		ldi r16,0x87		//initialize ADC
		sts	ADCSRA,r16		//set the initialized ADC into the ADC control and status A
		ldi r16,0x40		//initialize for ADC multiplexer with 0x40
		sts ADMUX,r16		//set the initialized value into the ADC multiplexer selection.
		ldi r16,0			//initialize ADC
		sts ADCSRB,r16		//set the initialized ADC into the ADC control and status B
		ldi r16,0xFE		//Initialize disable value
		sts DIDR0,r16		//Digital disable register 0 with 0xFE
		ldi r16,0xFF		//initialize diable value
		sts DIDR1,r16		//Digital disable register 0 with 0xFF
		ret					//return status of the initalization, and returns the stack pointer.
	
//Kaden
.global LCD_Write_Command
LCD_Write_Command:
	call	UART_Off		//disables reciever and transistor
	ldi		r16,0xFF		;PD0 - PD7 as outputs
	out		DDRD,r16		//store the data into DDRD to determine if pin D is ussed for input or output
	lds		r16,DATA		//load DATA into register 16
	out		PORTD,r16		//use the data in the register storing it in the address to port D
	ldi		r16,4			//load 4 into register 16
	out		PORTB,r16		//use the data in the register storing it in the address to port B
	call	LCD_Delay		//Call some delay to give it time for the port
	ldi		r16,0			//load 0 into register 16
	out		PORTB,r16		//use the data in the register storing it in the address to port B
	call	LCD_Delay		//Call some delay to give it time for the port
	call	UART_On			//enable reciever and transistor
	ret						//returns the write command and stack pointer

.global LCD_Delay
LCD_Delay:
	ldi		r16,0xFA		//loads 0xFA into register 16
D0:	ldi		r17,0xFF		//loads 0xFF into register 17
D1:	dec		r17				//decrement value in register 17 by 1
	brne	D1				//without zero flag it will go back to D1
	dec		r16				//decrement value in register 16 by 1
	brne	D0				//without zero flag it will go back to D0
	ret						//return the stack pointer, and provided a delay

.global LCD_Write_Data
LCD_Write_Data:
	call	UART_Off		//disables reciever and transistor
	ldi		r16,0xFF		//PD0 - PD7 as outputs
	out		DDRD,r16		//store the data into DDRD to determine if pin D is ussed for input or output
	lds		r16,DATA		//load DATA into register 16
	out		PORTD,r16		//use the data in the register storing it in the address to port D
	ldi		r16,6			//load 6 into register 16
	out		PORTB,r16		//use the data in the register storing it in the address to port B
	call	LCD_Delay		//Call some delay to give it time for the port
	ldi		r16,0			//load 0 into register 16
	out		PORTB,r16		//use the data in the register storing it in the address to port B
	call	LCD_Delay		//Call some delay to give it time for the port
	call	UART_On			//enable reciever and transistor
	ret						//returns the write data and stack pointer (write to the LCD)

.global LCD_Read_Data
LCD_Read_Data:
	call	UART_Off		//disables reciever and transistor
	ldi		r16,0x00		//setting the value for ports
	out		DDRD,r16		//store the data into DDRD to determine if pin D is ussed for input or output
	out		PORTB,4			//use the data 4 storing it in the address to port B
	in		r16,PORTD		//Taking what is at port D data register and taking it in as input
	sts		DATA,r16		//load register 16 into DATA
	out		PORTB,0			//use the data 0 storing it in the address to port B
	call	UART_On			//enable reciever and transistor
	ret						//returns the read data and stack pointer (LCD can read it)

//Austin
.global UART_On
UART_On:
	ldi		r16,2				//student comment here
	out		DDRD,r16			//set data direction register to 00000010
	ldi		r16,24				
	sts		UCSR0B,r16			//Enables UART reciever and transmitter
	ret						

.global UART_Off
UART_Off:
	ldi	r16,0					
	sts UCSR0B,r16				//disables reciever and transmitter
	ret					

.global UART_Clear
UART_Clear:
	lds		r16,UCSR0A			//recives register status from UART
	sbrs	r16,RXC0			//skips next line if data was recieved
	ret							
	lds		r16,UDR0			//puts data into register, clears memory address
	rjmp	UART_Clear			//jumps back to begining

.global UART_Get
UART_Get:
	lds		r16,UCSR0A			//recives register status from UART
	sbrs	r16,RXC0			//skips next line if data was recieved
	rjmp	UART_Get			//jumps back if data was not recieved
	lds		r16,UDR0			//recives data 
	sts		ASCII,r16			//puts data into ASCII
	ret							

.global UART_Poll
UART_Poll:
	lds		r18,UCSR0A			//recives register status from UART
	sbrs	r18,RXC0			//skips next line if data was recieved
	ret
	lds		r18,UDR0			//recives data 
	sts		ASCII,r18			//puts data into ASCII
	ret	
	
.global UART_Put
UART_Put:
	lds		r17,UCSR0A			//recives register status from UART
	sbrs	r17,UDRE0			//skips next line if UART not in transmitting mode
	rjmp	UART_Put
	lds		r16,ASCII			//recieves put data
	sts		UDR0,r16			//outputs data
	ret	

//Mason
.global ADC_Get
ADC_Get:
	ldi		r16,0xC7			//Sets 0xC7 to register 16 to be loaded into address ADCSRA  
	sts		ADCSRA,r16			//r16 is stored to address ADSRA for use in loop
A2V1:
	lds		r16,ADCSRA			//loads value stored in ADSRA to r16 a reset of the value
	sbrc	r16,ADSC			//If the bit in r16 is cleared skips the next instruction, this will end the loop
	rjmp 	A2V1				//Jumps back to A2V1 to create loop 
	lds		r16,ADCL			//The low value of the ADC port is stored in r16
	sts		LADC,r16			//Then the value of ADCL is loaded into a global address to be used in C program
	lds		r16,ADCH			//The high value of the ADC port is stored in r16
	sts		HADC,r16			//Then stored to the global address HADC to be used in C program
	ret							//Returns to the section where call was made

.global EEPROM_Write
EEPROM_Write:      
	sbic    EECR,EEPE
	rjmp    EEPROM_Write		; Wait for completion of previous write
	lds		r18,EELOCH			; Set up address (r18:r17) in address register
	lds		r17,EELOCL 
	ldi		r16,'F'				; Set up data in r16    
	out     EEARH, r18      
	out     EEARL, r17			      
	out     EEDR,r16			; Write data (r16) to Data Register  
	sbi     EECR,EEMPE			; Write logical one to EEMPE
	sbi     EECR,EEPE			; Start eeprom write by setting EEPE
	ret 

.global EEPROM_Read
EEPROM_Read:					    
	sbic    EECR,EEPE    
	rjmp    EEPROM_Read			; Wait for completion of previous write
	lds		r18,EELOCH			; Set up address (r18:r17) in EEPROM address register
	lds		r17,EELOCL
	ldi		r16,0x00   
	out     EEARH, r18   
	out     EEARL, r17		   
	sbi     EECR,EERE			; Start eeprom read by writing EERE
	in      r16,EEDR			; Read data from Data Register
	sts		ASCII,r16  
	ret

	
.global EEMEMORYH
EEMEMORYH:
		lds	r16, EELOCH		//adds value of data to high EEPROM location
		lds	r17, DATA
		add	r16, r17
		sts	EELOCH, r16		//used to get input memory location
		ret

.global EEMEMORYL
EEMEMORYL:
		lds	r16, EELOCL		//adds value of data to low EEPROM location
		lds	r17, DATA
		add	r16, r17
		sts	EELOCL, r16		//used to get input memory location
		ret
			
.global EEMEMORYR
EEMEMORYR:
		ldi	r16, 0			//resets EEPROM memory location to 0
		sts	EELOCH, r16
		sts 	EELOCL, r16
		ret

.global SETC
SETC: 
	lds		r16, UCSR0C		//sets bits in UCSR0C that are high in USARTDATA
	lds		r17, USARTDATA
	or		r16, r17
	sts		UCSR0C, r16		//used to change parity, #of stop bits, and character size
	ret		

.global CLEARC
CLEARC: 
	lds		r16, UCSR0C		//clears bits in UCSR0C that are high in USARTDATA
	ldi		r17, 0xFF
	lds		r18, USARTDATA
	sub		r17, r18
	and		r16, r17		
	sts		UCSR0C, r16		//used to change parity, #of stop bits, and character size
	ret

.global SETB
SETB: 
	lds		r16, UCSR0B		//sets bits in UCSR0B that are high in USARTDATA
	ldi		r17, 0xFF
	lds		r18, USARTDATA
	sub		r17, r18
	and		r16, r17
	sts		UCSR0B, r16		//used to change character size
	ret
	
.global CLEARB
CLEARB:
	lds		r16, UCSR0B		//clears bits in UCSR0B that are high in USARTDATA
	lds		r17, USARTDATA
	or		r16, r17
	sts		UCSR0B, r16		//used to change character size
	ret

.global SETBAUD
SETBAUD:
	lds		r16, BAUDL	//sets the baud rate using the BAUDL and BAUDH registers
	lds		r17, BAUDH
	sts		UBRR0L,r16
	sts		UBRR0H,r17
	ret

.end



