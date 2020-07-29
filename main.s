	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s    
		
	IMPORT LCD_Initialization
	IMPORT LCD_Clear
	IMPORT LCD_DisplayString
	

	

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	bl LCD_Initialization
	bl LCD_Clear
	ldr r4,=RCC_BASE
	ldr r5,[r4,RCC_AHB2ENR]
	orr r5,#0x11
	str r5,[r4,RCC_AHB2ENR]
	ldr r4,=GPIOE_BASE
	ldr r5,=GPIOA_BASE
	ldr r6,[r4,GPIO_MODER]
	bic r6,#0xff00000
	orr r6,#0x5500000
	str r6,[r4,GPIO_MODER]
	ldr r6,[r5,GPIO_MODER]
	ldr r10,=0xcfc
	bic r6,r10
	str r6,[r5,GPIO_MODER]
	b main_loop
	;end setup
	


display 
	bl lcd_write
	bl LCD_DisplayString
debounce 
	ldr r1,[r5,GPIO_IDR]
	and r2,r1,#0x2e
	cmp r2,#0x2e
	bne debounce
main_loop 
	ldr r6, [r4,GPIO_ODR]
	orr r6,#0x3c00
	bic r6,#0x3c00
	str r6, [r4,GPIO_ODR]
loop3 mov r2,#0xf		;delay
loop3_a subs r2,#1
	  bne loop3_a
	  ldr r1,[r5,GPIO_IDR]
	  ;bfc r1,#13,#19
	  and r2,r1,#0x2e
	  cmp r2,#0x2e
	  beq main_loop				;If all ones return to main
	  
	  ldr r6, [r4,GPIO_ODR]
	  orr r6,#0x3c00
	  bic r6,#0x400
	  str r6, [r4,GPIO_ODR]
	  mov r0,#0
	  bl btn_check
	  
	  ldr r6, [r4,GPIO_ODR]
	  orr r6,#0x3c00
	  bic r6,#0x800
	  str r6, [r4,GPIO_ODR]
	  mov r0,#1
	  bl btn_check
	  
	  ldr r6, [r4,GPIO_ODR]
	  orr r6,#0x3c00
	  bic r6,#0x1000
	  str r6, [r4,GPIO_ODR]
	  mov r0,#2
	  bl btn_check
	  
	  ldr r6, [r4,GPIO_ODR]
	  orr r6,#0x3c00
	  bic r6,#0x2000
	  str r6, [r4,GPIO_ODR]
	  mov r0,#3
	  bl btn_check
	  
	  b main_loop
	  
	

	
  

stop 	B 		stop     		; dead loop & program hangs here
	ENDP
		
lcd_write PROC
	cmp r0,#0x0
		moveq r1,#49
		cmp r0,#0x1
		moveq r1,#50
		cmp r0,#0x2
		moveq r1,#51
		cmp r0,#0x3
		moveq r1,#65
		cmp r0,#0x4
		moveq r1,#52
		cmp r0,#0x5
		moveq r1,#53
		cmp r0,#0x6
		moveq r1,#54
		cmp r0,#0x7
		moveq r1,#66
		cmp r0,#0x8
		moveq r1,#55
		cmp r0,#0x9
		moveq r1,#56
		cmp r0,#0xa
		moveq r1,#57
		cmp r0,#0xb
		moveq r1,#67
		cmp r0,#0xc
		moveq r1,#42
		cmp r0,#0xd
		moveq r1,#48
		cmp r0,#0xe
		moveq r1,#47
		cmp r0,#0xf
		moveq r1,#68
		
		ldr r0,=string
		ldrb r2,[r0,#4]
		strb r2,[r0,#5]
		ldrb r2,[r0,#3]
		strb r2,[r0,#4]
		ldrb r2,[r0,#2]
		strb r2,[r0,#3]
		ldrb r2,[r0,#1]
		strb r2,[r0,#2]
		ldrb r2,[r0]
		strb r2,[r0,#1]
		strb r1, [r0]
		bx lr
	
	
	
	
	
	endp
		
btn_check proc			; input: r0 - row  r1-idr
	mov r2,#0xfff		;delay
loop_a	subs r2,#1
	bne loop_a
	ldr r1,[r5,GPIO_IDR]
	and r2,r1,#0x2e
	cmp r2,#0x2e
	bxeq lr				;If all ones return to main
	and r2,r1,#0x2
	cmp r2,#0x2
	movne r3,#0
	bne jmp
	
	and r2,r1,#0x4
	cmp r2,#0x4
	movne r3,#1
	bne jmp
	
	and r2,r1,#0x8
	cmp r2,#0x8
	movne r3,#2
	bne jmp
	
	and r2,r1,#0x20
	cmp r2,#0x20
	movne r3,#3
	bne jmp
	

jmp	mov r10,#4
	mul r0,r0,r10
	add r0,r3
	b display
	
	
	
	endp
	
					
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN

; Replace ECE0202 with your last name
string DCB 0,0
	END
