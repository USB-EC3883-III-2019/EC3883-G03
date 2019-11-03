import processing.serial.*;  // Libreria para el uso del puerto serial

byte posicion;
byte sentido = 0;                // controlo el sentido de de barrido del radar
byte[] leer = new byte[4];        // arreglo donde se va a guardar la data recibida por puerto serial

int[] lidar = new int[128];
int[] sonar = new int[128];
int[] solindar = new int[128];

byte i = 0;

int bsx, bsy;
int blx, bly;
int bslx, bsly;
int bsize = 50;     // Tamano de los botones a usar

color bs, bl, bsl;  // color de los botones de de sonar, lidar y solindar
color bhl;          // color que representa cuando me situo sobre un boton

boolean bsover = false;
boolean blover = false;
boolean bslover = false;

boolean bson = false;
boolean blon = false;
boolean bslon = false;
boolean filtro = false;

PrintWriter log;

Serial myPort;      // Crea un objeto de clase serial

void setup() {
  
  size(1200,1200);
  background(0);

  bs = color(0,0,150);
  bl = color(150,0,0);
  bsl = color(150,0,150);
  bhl = color(150,150,150);
  
  bsx = 525;
  blx = 600;
  bslx = 675;
  
  bsy = bly = bsly = 800;
  
  log = createWriter("log.txt");
  log.print("Registro de la data: \n\n");

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.buffer(8);
}

void draw() {
  
  if (i == 1){
    
    clear();
    desentramado();
    
    radar();
    estatus_botones();
    
    
    println("sonar|lidar|solindar =  " +sonar[posicion]+ "|"+lidar[posicion]+ "|"+solindar[posicion]);
    
    if(bson == true){
      sonar();
      stroke(255);
      fill(0,255,0);
      circle(bsx, bsy - 50, 20); 
    } else{
      stroke(255);
      fill(0,0,0);
      circle(bsx, bsy - 50, 20);
    }
    
    noFill();
    
    if(blon == true){
      lidar();
      stroke(255);
      fill(0,255,0);
      circle(blx, bly - 50, 20); 
    } else{
      stroke(255);
      fill(0,0,0);
      circle(blx, bly - 50, 20);
    }
    
    noFill(); 
     
    if(bslon == true){
      solindar();
      stroke(255);
      fill(0,255,0);
      circle(bslx, bsly - 50, 20); 
    } else{
      stroke(255);
      fill(0,0,0);
      circle(bslx, bsly - 50, 20);
    }
    
    noFill();

    if(filtro == true){
      stroke(255);
      fill(0,255,0);
      circle(1069, 120, 20); 
    } else {
      stroke(255);
      fill(0,0,0);
      circle(1069, 120, 20);
    }
    
    noFill();
    
    bitacora(); 
     
    i = 0;
    
    fill(255);
    rect(bsx-20,bsy+40,40,10);
    
    fill(255);
    rect(blx-20,bly+40,38,10);
    
    fill(255);
    rect(bslx-28,bsly+40,63,10);
    
    fill(255);
    rect(1050,150,40,10);
    
    stroke(255);
    fill(0,0,255);
    text("Sonar",bsx - 20, bsy + 50);
    
    stroke(255);
    fill(255,0,0);
    text("Lidar",blx - 18, bly + 50);
    
    stroke(255);
    fill(255,0,255);
    text("SoLindar",bslx - 27, bsly + 50);
    
    stroke(255);
    fill(0);
    text("Filtro",1050, 161);
    
    noFill();
    noStroke();
  }
}

//////////////////////////////////// Funciones //////////////////////////////////////////

void serialEvent(Serial myPort) {

 if ((myPort.available() > 0) && (i == 0)) {
    do {
    leer[0] = byte(myPort.read());
    } while (int(leer[0]) > 127);
    leer[1] = byte(myPort.read());
    leer[2] = byte(myPort.read());
    leer[3] = byte(myPort.read());
 } 
    //print(" ( "+ int(leer[0]) + " "+ int(leer[1]) +" "+ int(leer[2]) +" "+ int(leer[3]) +" ) ");
    i = 1;
 
}

void desentramado() {                       // funcion que nos permite desempaquetar la data recibida del puerto serial, para su posterior uso
  
  int[] aux = new int[2];                 // defino una variable auxiliar para el proceso desempaquetado
  
  if(int(leer[1]) > 191)
    filtro = true;
  else
    filtro = false;
  
  aux[0] = leer[0];                   // aux[0] = leer[0] en valor char, ya que leer[i] es una variable tipo byte
  posicion = byte(aux[0]);                  // posicion = aux[0] en valor byte, con esto tengo la posicion actual del motor
  
  aux[0] = leer[1] & 63;              // hago un AND de leer[1] con 0011111, para limpiarme el bit de cabecera y el del filtro
  aux[0] = aux[0] << 2;               // shifteo 2 bits a la izquierda para incluir los otros bit faltantes del sonar
  aux[1] = leer[2] & 96;              // hago AND de leer[2] con 01100000, para limpiar el bit de cabecera y la data que no es del sonar
  aux[1] = aux[1] >> 5;               // shifteo 5 bits a la izquierda la data de aux[1] para luego combinarla con aux[0] y tener la data del sonar
  sonar[posicion] = (aux[0] | aux[1])*61/58;  // uno la data de aux[0] y aux[1] y la guardo en sonar en la posicion que le corresponde 61us / 58cm

  aux[0] = leer[2] & 31;                // hago AND de leer[2] con 00011111, para limpiar el bit de la cabecera y la data que no es del lidar
  aux[0] = aux[0] << 7;                 // shifteo 7 bits a la izquierda para incluir los bits bastante del lidar
  aux[1] = leer[3] & 127;               // hago AND de leer[3] con 01111111, para limpiar el bit de cabecera
  lidar[posicion] = (aux[0] | aux[1]);  // uno la data de aux[0] y aux[1] y la guar en lidar en la posicion que le corresponde
  lidar[posicion] = int(369577*pow(lidar[posicion], -1.42));

  
  if((lidar[posicion]>80) && (sonar[posicion]<80))
      solindar[posicion] = sonar[posicion];

  else  if ((lidar[posicion] < 10) && (sonar[posicion] < 80))
      solindar[posicion] = sonar[posicion];

  else if((lidar[posicion]<80) && (sonar[posicion]>80))
      solindar[posicion] = lidar[posicion];  
 
  else if((lidar[posicion]>80) && (sonar[posicion]>80))
      solindar[posicion] = (sonar[posicion] + lidar[posicion])/2;    
    
  else  if(abs(sonar[posicion] - lidar[posicion]) < 5)
    solindar[posicion] = (sonar[posicion] + lidar[posicion])/2;
  else
    solindar[posicion] = sonar[posicion];
  
}

void mousePressed(){

  if (bsover) {                  // Comprobacion de que el mouse fue presionado encima del boton del sonar
    if(bson == false) {          // Comprobacion que indica si el boton del sonar estaba previamente apagado
      bson = true;               // Activacion de la muestra de data del sonar
    } else bson = false;         // Desactivacion de la muestra de data del sonar
  }
 
  if (blover) {                  // Comprobacion de que el mouse fue presionado encima del boton del lidar
    if(blon == false) {          // Comprobacion que indica si el boton del lidar estaba previamente apagado
      blon = true;               // Activacion de la muestra de data del lidar
    } else blon = false;         // Desactivacion de la muestra de data del lidar
  }  
  
  if (bslover) {                  // Comprobacion de que el mouse fue presionado encima del boton del solindar
    if(bslon == false) {          // Comprobacion que indica si el boton del solindar estaba previamente apagado
      bslon = true;               // Activacion de la muestra de data del solindar
    } else bslon = false;         // Desactivacion de la muestra de data del solindar
  }

}

boolean overCircle(int x, int y, int diameter) {    //  Funcion que permite identificar si el puntero esta sobre uno de los botones
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
} 

void update(int x, int y){
  
  if(overCircle(bsx, bsy, bsize)){
    bsover = true;
    blover = false;
    bslover = false;
  }
  else if(overCircle(blx, bly, bsize)){
    bsover = false;
    blover = true;
    bslover = false;  
  }
  else if(overCircle(bslx, bsly, bsize)){
    bsover = false;
    blover = false;
    bslover = true;  
  } 
  else bsover = blover = bslover = false;
  
}

void estatus_botones(){

  update(mouseX, mouseY);       // Comprueba el estado de la posicion del puntero respecto a los botones 
  
  // Seccion para el dibujo de los botones
  
  if (bsover) {
    fill(bhl);
  } else {
    fill(bs);
  }
  stroke(255);
  ellipse(bsx, bsy, bsize, bsize);
  
    if (blover) {
    fill(bhl);
  } else {
    fill(bl);
  }
  stroke(255);
  ellipse(blx, bly, bsize, bsize);
  
    if (bslover) {
    fill(bhl);
  } else {
    fill(bsl);
  }
  stroke(255);
  ellipse(bslx, bsly, bsize, bsize);
  
  noFill();
  noStroke();
  
}

void radar() {

  float dia = 112.5; // 112.5 representa el diametro de 20cm 
  float px; // valor de posicion en X recibida movida en el angulo
  float py; // valor de posicion en Y recibida movida en el angulo
  
  float ang_m = float(posicion)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
        ang_m = ang_m - PI/4;
    
  stroke(0,255,0);
  strokeWeight(2);
  
  // Dibujo del radar
  
  arc(width/2,height/2, dia, dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 2*dia, 2*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 3*dia, 3*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 4*dia, 4*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 5*dia, 5*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 6*dia, 6*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 7*dia, 7*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 8*dia, 8*dia, -5*PI/4, PI/4);
  arc(width/2,height/2, 9*dia, 9*dia, -5*PI/4, PI/4, PIE);
  
  arc(width/2,height/2, 8*dia, 8*dia, -5*PI/4, -PI, PIE);
  arc(width/2,height/2, 8*dia, 8*dia, -PI, -3*PI/4, PIE);
  arc(width/2,height/2, 8*dia, 8*dia, -3*PI/4, -PI/2, PIE);
  arc(width/2,height/2, 8*dia, 8*dia, -PI/2, -PI/4, PIE);
  arc(width/2,height/2, 8*dia, 8*dia, -PI/4, 0, PIE);
  
  // Texto de distancias
  textSize(15);
  fill(0,255,0);
  text("80",width/2+5,165);
  text("70",width/2+5,221.75);
  text("60",width/2+5,278.5);
  text("50",width/2+5,335.25);
  text("40",width/2+5,392);
  text("30",width/2+5,448.75);
  text("20",width/2+5,505.5);
  text("10",width/2+5,562.25);
  // Fin de texto de distancias
  
  // Texto de angulos
  text("135°",width/2-15,128.375);
  
  pushMatrix();
  translate(952,926);
  rotate(3*PI/4);
  text("0°",0,0);
  popMatrix();
  
  pushMatrix();
  translate(255,937);
  rotate(-3*PI/4);
  text("270°",0,0);
  popMatrix();
  // Fin de texto de angulos
  
  // Fin del dibujo
    
  fill(0,10);
  
  rect(0,0,width,height);
  
  px = width/2 + cos( ang_m  )*450;
  py = height/2 - sin( ang_m  )*450;
  
  stroke(0,255,255);
  strokeWeight(5);
  line(width/2,height/2,px,py);
      
  noFill();
  noStroke();
      
}

void sonar(){
  float px; // valor de posicion en X recibida movida en el angulo
  float py; // valor de posicion en Y recibida movida en el angulo
  
  float ang_m = float(posicion)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
        ang_m = ang_m - PI/4;
      
rect(0,0,width,height);
       
  for(byte i = 0; i<73; i ++){
    
    ang_m = float(i)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
    ang_m = ang_m - PI/4;
    
    px = width/2 + cos(ang_m)*sonar[i]*5.6;       
    py = height/2 - sin(ang_m)*sonar[i]*5.6;
    
    if(sonar[i] != 0){
      stroke(0,0,255);
      strokeWeight(3);
      fill(255);
      if (sonar[i]<= 80) circle(px,py, 10);
    }
  }
  
  noFill();
  noStroke();
}

void lidar(){
  float px; // valor de posicion en X recibida movida en el angulo
  float py; // valor de posicion en Y recibida movida en el angulo
  
  float ang_m = float(posicion)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
        ang_m = ang_m - PI/4;
      
rect(0,0,width,height);
       
  for(byte i = 0; i<73; i ++){
    
    ang_m = float(i)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
    ang_m = ang_m - PI/4;
    
    px = width/2 + cos(ang_m)*lidar[i]*5.6;
    py = height/2 - sin(ang_m)*lidar[i]*5.6;
    
    if(lidar[i] != 0){
      stroke(255,0,0);
      strokeWeight(3);
      fill(255);
      if (lidar[i]<= 80) circle(px,py, 10);
    }
  }
  
  noFill();
  noStroke();
}

void solindar(){
  float px; // valor de posicion en X recibida movida en el angulo
  float py; // valor de posicion en Y recibida movida en el angulo
  
  float ang_m = float(posicion)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
        ang_m = ang_m - PI/4;
      
rect(0,0,width,height);
       
  for(byte i = 0; i<73; i ++){
    
    ang_m = float(i)*3.75*2*PI/360;        // Convierto el valor de posicion en radianes
    ang_m = ang_m - PI/4;
    
    px = width/2 + cos(ang_m)*solindar[i]*5.6;
    py = height/2 - sin(ang_m)*solindar[i]*5.6;
    
    if(solindar[i] != 0){
      stroke(255,0,255);
      strokeWeight(3);
      fill(255);
      if (solindar[i]<= 80) circle(px,py, 10);
    }
  }
  
  noFill();
  noStroke();
}

void bitacora(){

  float angulo = posicion*3.75;
  log.print("Angulo: " +angulo+ "°\t Sonar: "+ int(sonar[posicion])+"cm\t Lidar: "+ int(lidar[posicion])+ "cm\t SoLindar: "+ int(solindar[posicion]) +"cm \n");

}
