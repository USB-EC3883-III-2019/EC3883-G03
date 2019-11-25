

int ResetX, ResetY;  //variable de la posición del boton Torre4
int EnterX, EnterY;  //variable de la posición del boton Torre4

int ResetSize = 30;       // variable del tamano del boton de T4
int EnterSize = 30;       // variable del tamano del boton de T4


void setup () {

size (500, 600);
background(#050001); // Fondo color negro

stroke (255,0,0); //color borde rojo
strokeWeight (5); //grosor 5
fill (0,255,0); // relleno verde
rect (50,50,400,100);//rectángulo

rect (50,220,50,20);//rectángulo Maestro / Esclavo

rect (50,300,50,20);//rectángulo Zona 0
rect (120,300,50,20);//rectángulo Zona 1
rect (190,300,50,20);//rectángulo Zona 2
rect (260,300,50,20);//rectángulo Zona 3
rect (330,300,50,20);//rectángulo Zona 4
rect (50,370,50,20);//rectángulo Mensaje a enviar


EnterX = 175;
EnterY = 380;

ResetX = 275;
ResetY = 380;


  fill(#2088C6);
//  textFont(mono);
  text("Mensaje Visual",200,30);  
 
  
  fill(#2088C6);
//  textFont(mono1);
  text("ER instruments",10,585);
  
  fill(#2088C6);
//  textFont(mono2);
  text("Configuracion:",40,210);
  text("Maestro / Esclavo",30,260);

fill(#2088C6);
////  textFont(mono2);
text("Zonas:",50,290);
text("Zona 0",55,335);
text("Zona 1",127,335);
text("Zona 2",197,335);
text("Zona 3",267,335);
text("Zona 4",337,335);
  




fill(#2088C6);
 //// textFont(mono2);
text("Mensaje a enviar",30,410);
text("Enter",160,410);
text("Reset",260,410);

}

void draw() { 


fill (0,255,0); // relleno verde
ellipse(ResetX, ResetY, ResetSize, ResetSize);
ellipse(EnterX, EnterY, EnterSize, EnterSize);

}
