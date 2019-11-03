/* ###################################################################
**     Filename    : main.c
**     Project     : Solindar_pro
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
#include "KB1.h"
#include "Bit1.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */

char flag_motor;     // Bandera a usar para el envio de bits de movimiento del motor
char block[4];       // Variable donde se guardara el entramado a enviar
char adc[2];         // Variable que guardara el resultado obtenido por el ADC para el sensor lidar
char bandera;

char lidar[2];       // Variable que registara el valor obtenido por el lidar 
char sonar[2];       // Variable que guardara la distancia obtenida por sonar
char filtro = 0;

char *DirBlock;           // puntero que me permite enviar data por puerto serial
char posicion = 0;        // Variable que registrara el valro de posicion del motor
char mot_TI = 0;          // flag de la interrupcion de entrada del motor
signed char edo_mot = 0;  // variable de control del estado actual del motor
char dir_mot = 0;         // variable de control de la direccion de movimiento del motor
char total_ciclo = 9;     // Total de ciclos a girar 9
char ciclo = 0;           // contador inicial del numero de ciclos que tomara el motor

char capture[2];
int capture2[2];

char adc[2];
int adc2[2];
int contador = 0;

/* 	Notas: reconfigurar el periodo del PWM para el uso del trigger para el ultrasonido
	Captures es usado para medir el ancho del pulso del ultrasonido link: https://github.com/JuanOcando/Proyectos2/wiki/Configuracion-del-DEMOQE128

	Usar casting a la hora de unir variables de multiples tipos. Ej: char var = (char) int_var;
	
*/
void capture_procesado(){
	
	char aux3;

	aux3 = capture[0] & 0b00000001;
	sonar[0] = aux3 << 4;
	
	aux3 = capture[1] & 0b11110000;
	aux3 = aux3 >> 4;
	sonar[0] = sonar[0] | aux3;
	
	sonar[1] = capture[1] & 0b00001111;
	
}

void adc_procesado(){
	
	//char aux2[2];
	char aux3;

	aux3 = adc[0] & 0b00001111;
	lidar[0] = aux3 << 1;
	
	aux3 = adc[1] & 0b10000000;
	aux3 = aux3 >> 7;
	lidar[0] = lidar[0] | aux3;
	
	lidar[1] = adc[1] & 0b01111111;
	
}

void entramado()       // Funcion encargada del entramado de la data que sera transmitida
{
	char aux;                                 // Variable auxiliar usada para auxiliar en la fusion de informacion separada
	
	block[0] = posicion & 0b01111111;         // Bloque 1 listo. Solo contiene 6 bits de la pos. del motor (63 int como valor maximo)
	
	block[1] = (sonar[0]<<2) & 0b01111100;    // Entramado del bloque 1 asumiendo que sonar[0] tiene 5 bits significativos
	aux = (sonar[1]>>2) & 0b00000011;         // y sonar[1] tiene solo 4 bits significativos
	block[1] = block[1] | aux;
	block[1] = block[1] | 0b10000000;         // Bloque 1 listo
	
	if (filtro == 1)
		block[1] = block[1] | 0b11000000;
	
    block[2] = (lidar[0]) & 0b00011111;       // Empaqueto los 5 bits mas significativos obtenidos del lidar
    aux = (sonar[1]<<5) & 0b01100000;         // guardo en aux los 2 bits menos sig de sonar[1] corridos 5 pos. a la izquierda
    block[2] = aux | block[2];                // junto la informacion del sonar y lidar que corresponden con el bloque 2
    block[2] = block[2] | 0b10000000;         // Bloque 2 listo
    
    block[3] = (lidar[1]) & 0b01111111; // junto el bit menos significativo de lidar[0] con los 6 de lidar[1]
	block[3] = block[3] | 0b10000000;         // Bloque 3 listo
    
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
	
	if ((edo_mot > 7) && (dir_mot == 0)){
		edo_mot = 0;
		ciclo = ciclo + 1;	
	}

	if ((edo_mot < 0) && (dir_mot == 1)){
		edo_mot = 7;  
		ciclo = ciclo - 1;	
	}	
	
	if ((ciclo == total_ciclo) && (dir_mot == 0)){
		dir_mot = 1;
		edo_mot = 7;
	}
	
	if ((ciclo == 0) && (dir_mot == 1)){
		dir_mot = 0;
		edo_mot = 0;
	}	
	
	
}

void main(void)
{
  /* Write your local variable definition here */
	
  Bit1_SetVal();
  adc2[1] = 0;
  capture[1] = 0;
  bandera = 0;
  
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
  
  do{
	  if (filtro == 1)
		  Bit1_ClrVal();
	  else if (filtro == 0)
		  Bit1_SetVal();
	  
	  if (mot_TI == 1){
	    
		if((filtro == 1) && (bandera == 0)){
			contador = 1;
			bandera = 1;
		}		
		if(filtro == 0)
			contador = 0;
			
		AD1_Measure(1);
		AD1_GetValue(adc2);
		
		if(filtro == 0){
			adc2[1] = adc2[0];
			capture2[1] = capture2[0];
		} else if (filtro == 1){
			adc2[1] = adc2[1] + adc2[0];
			capture2[1] = capture2[1] + capture2[0];
		}
		
		if (contador == 0){
		
			if(filtro == 1){
				adc2[1] = adc2[1] >> 1;
				capture2[1] = capture2[1] >> 1; // En ambos casos divido entre 2 el resultado para obtener el promedio
			}
			
			adc[0] = (adc2[1] >> 8) & 15;  // 15 = 0b00001111
			adc[1] = adc2[1] & 255;
			capture[0] = (capture2[1] >> 8) & 1;
			capture[1] = capture2[1] & 255;  // 255 = 0b11111111
			
			adc_procesado();	
			capture_procesado();
			entramado();
			paso_mot();  
			AS1_SendBlock(block, 4, &DirBlock);
			  
			adc2[1] = 0;
			capture2[1] = 0;
			bandera = 0;
		}
		
		mot_TI = 0;
		
		if(filtro == 1)
			contador = contador - 1;
		
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
