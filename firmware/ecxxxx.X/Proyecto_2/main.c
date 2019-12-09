/* ###################################################################
**     Filename    : main.c
**     Project     : LP3_P2
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-11-01, 11:18, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "MBit1.h"
#include "Inhr1.h"
#include "Inhr2.h"
#include "Inhr3.h"
#include "Inhr4.h"
#include "TI1.h"
#include "PWM1.h"
#include "AS1.h"
#include "AD1.h"
#include "Cap1.h"
#include "AS2.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */

char flag_motor;     // Bandera a usar para el envio de bits de movimiento del motor
char block[4];       // Variable donde se guardara el entramado a enviar
char block2[4];       // Variable donde se guardara el entramado a enviar

char *DirBlock;           // puntero que me permite enviar data por puerto serial
char posicion = 0;        // Variable que registrara el valro de posicion del motor
char mot_TI;              // flag de la interrupcion de entrada del motor
signed char edo_mot = 0;  // variable de control del estado actual del motor
char dir_mot = 0;         // variable de control de la direccion de movimiento del motor
char total_ciclo = 9;     // Total de ciclos a girar 9
char ciclo = 0;           // contador inicial del numero de ciclos que tomara el motor

char rblock [5];
char rblock2 [8];
char reci = 0;
char reci2 = 0;
char master = 0;
char momo = 0;
char max = 0;
char min = 0;
char i = 0;

/* 	Notas: reconfigurar el periodo del PWM para el uso del trigger para el ultrasonido
	Captures es usado para medir el ancho del pulso del ultrasonido link: https://github.com/JuanOcando/Proyectos2/wiki/Configuracion-del-DEMOQE128

	Usar casting a la hora de unir variables de multiples tipos. Ej: char var = (char) int_var;
	
*/

void slave()       // Funcion encargada de quitar la zona que le corresponde
{
	int aux[4];                                 // Variable auxiliar usada para auxiliar en la fusion de informacion separada
	
	aux[0] = block2[2] & 0b00111000;
	aux[1] = block2[2] & 0b00000111;
	aux[2] = block2[3] & 0b00111000;
	aux[3] = block2[3] & 0b00000111;
	
	if(aux[0] != 0){
		block2[2] = block2[2] &0b00000111;
		aux[0] = aux[0] >> 3;
		max = aux[0]*12;
	}
	else if(aux[1] != 0){
		block2[2] = block2[2] &0b00000000;
		max = aux[1]*12;
		
	}
	else if(aux[2] != 0){
		block2[3] = block2[3] &0b00000111;
		aux[2] = aux[2] >> 3;
		max = aux[2]*12;
	}
	else if(aux[3] != 0){
		block2[3] = block2[3] &0b00000000;
		max = aux[3]*12;
	}	
    
}

void paso_mot(){
	
	if (edo_mot == 0) MBit1_PutVal(10); //Estado 1 - 1010 - LED 0101
	if (edo_mot == 1) MBit1_PutVal(8);  //Estado 2 - 1000 - LED 0111
	if (edo_mot == 2) MBit1_PutVal(9);  //Estado 3 - 1001 - LED 0110
	if (edo_mot == 3) MBit1_PutVal(1);  //Estado 4 - 0001 - LED 1110
	if (edo_mot == 4) MBit1_PutVal(5);  //Estado 5 - 0101 - LED 1010
	if (edo_mot == 5) MBit1_PutVal(4);  //Estado 6 - 0100 - LED 1011
	if (edo_mot == 6) MBit1_PutVal(6);  //Estado 7 - 0110 - LED 1001
	if (edo_mot == 7) MBit1_PutVal(2);  //Estado 8 - 0010 - LED 1101
	
	if(dir_mot == 0) {
		edo_mot = edo_mot + 1;
		posicion = posicion + 1; 
	}
	if(dir_mot == 1){
		edo_mot = edo_mot - 1;
		posicion = posicion - 1;
	}
	
	if (edo_mot > 7){
		edo_mot = 0;
		ciclo = ciclo + 1;	
	}

	if (edo_mot < 0){
		edo_mot = 7;  
		ciclo = ciclo - 1;	
	}	
	
	if(posicion <= min){
		dir_mot = 0;
	}		
	
	if(posicion >= max){
		dir_mot = 1;
	}
	if(posicion == (min+max)/2){
		dir_mot = 2;
	}
}

void main(void)
{
  /* Write your local variable definition here */
	
  mot_TI = 0;
  
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
  
  do{
	  if (mot_TI == 1){
		  
		if(momo == 1){  		  
			paso_mot();
		}
		if((posicion == (max+min)/2) && (momo == 1)){	
			if(master == 0){
				AS2_SendBlock(block2, 4, &DirBlock);
				AS1_SendBlock(block2, 4, &DirBlock);
			}
			if(master == 1){
				AS2_SendBlock(block, 4, &DirBlock);				
			}
		}	
		
		  mot_TI = 0;
	  }
	  
	  
	  if(reci == 1){
		  AS1_RecvBlock(rblock, 5, &DirBlock);
		  		  
		  block[0] = rblock[0];
		  block[1] = rblock[1];
		  block[2] = rblock[2];
		  block[3] = rblock[3];
		  
		  reci = 0;
		  
		  master = 1;
	  	  momo = 1;
	  	  max = rblock[4]*12;
	  	  min = max - 11;
	  }
	  
	  if(reci2 == 1){
		  AS2_RecvBlock(rblock2, 8, &DirBlock);
		  
		  do{
			  block2[0] = rblock2[i];
			  i = i + 1; 
		  }while ((block2[0]<128) || (block[0]>143));
		  
		  block2[1] = rblock2[i];
		  block2[2] = rblock2[i+1];
		  block2[3] = rblock2[i+2];

		  i = 0;
		  reci2 = 0;
		  
			  if (master == 1){	
			  	  AS1_SendBlock(block2, 4, &DirBlock);
		  	  }
		  	  if (master == 0){
			  	  slave();
			  	  min = max - 11;
			  	  momo = 1;
		  	  }
	  }
	  
  } while (1);
  
  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
