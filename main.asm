//encabezdo

.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN
.org 0x0006
	JMP ISR_PCINT0
MAIN:

// STACK


	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

// CONFIGURACIÓN

Setup:
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16			;Habilita prescaler
	LDI R16, 0b0000_0100
	STS CLKPR, R16	

	LDI R16, (1 << PC3)|(1 << PC2)|(1 << PC1)|(1 << PC0)
	OUT DDRC, R16

	LDI R16, 0
	OUT PORTC, R16

	SBI PORTB, PB0
	CBI DDRB, PB0

	SBI PORTB, PB1
	CBI DDRB, PB1



	LDI R16, (1 << PCINT1)|(1 << PCINT0)
	STS PCMSK0, R16

	LDI R16, (1 << PCIE0)|(1 << PCIE1)
	STS PCICR, R16

	SEI

	LDI R17, 0

Loop:
	
	RJMP Loop

ISR_PCINT0:
	
	PUSH R16
	IN R16, SREG
	PUSH R16

	IN R18, PINB

	CALL DelayBounce
	SBRC R18, PB0
	RJMP CHECKPB1
	INC R17
	CPI R17, 16
	BRNE Salir
	LDI R17, 15
	RJMP Salir
	
CHECKPB1:
	SBRC R18, PB1
	RJMP Salir
	DEC R17
	CPI R17, -1
	BRNE Salir
	LDI R17, 0
	RJMP Salir


Salir:
	OUT PORTC, R17
	CBI PINB, PB0
	SBI PCIFR, PCIF0
	POP R16
	OUT SREG, R16
	POP R16
	RETI

DelayBounce:			;Antirerebote (Suma del contador 1)
	LDI R16, 200	
	delay:				
		DEC R16			;Cuneta a 100
		BRNE delay		
	SBIS PINB, PB0		;Salta instrucción si PD4 está encendido
	RJMP DelayBounce	;Regresa a DelayBounce
	RETI

