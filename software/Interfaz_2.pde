import processing.serial.*;

char letra;
int mensaje;
int saltos = 0;
boolean modo = false;
boolean fms = false;       // flag que me define que configuracion ha sido elejida
boolean msj = false;
int x = 0;
int y = 20;

void setup() {
  
  size(800,800);
  background(0);
  
  textSize(15);
  text("Que configuracion desea usar? presione 'm' para maestro o 's' para esclavo.", 0, 15);
  
}

void draw(){
  
}

void keyPressed(){

  letra = key;
  
  if(fms == false){
    if(letra == 'm' || letra == 'M'){
      clear();
      text("Se ha seleccionado la configuracion de maestro.", 0, 15);
      fms = true;
      modo = true;
    }
    if(letra == 's' || letra == 'S'){
      clear();
      text("Se ha seleccionado la configuracion de esclavo.", 0, 15);
      fms = true;
    }
  }
 
 if(fms == true && modo == true){
   clear();
   text("Indique el numero de saltos que desea usar (entre 1 y 4).", 0, 15);
   
   if(int(letra) >= 49 && int(letra) <= 52){              // 48 es el valor int de 1 y 52 el de 4
     saltos = int(letra) - 48;
     clear();
     text("Se han definido " +saltos+ " saltos", 0, 15);
     modo = false;
     msj = true;
   }
 }
 
 if(msj == true){
   clear();
   text("Se le pedira que elija un numero entre 0 y 255 para enviar de mensaje.", 0, 15);
   text("Use la tecla '8' par aumentar el valor y el '2' para disminuir y enter para enviar.", 0, 30);
   
   if(int(letra) == 56)
     mensaje = mensaje + 1;
   if(int(letra) == 50) 
     mensaje = mensaje - 1;
     
   if(mensaje > 255)
     mensaje = 255;
   if(mensaje < 0)
     mensaje = 0;
   
   text(int(mensaje), 0, 45);
 }
 
}
