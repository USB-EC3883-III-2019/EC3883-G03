import processing.serial.*;    // Libreria para el uso del puerto serial

char tecla;                    // variable que guarda el valor de la tecla presionada
char control = 0;              // variable de control para las diferentes etapas de la configuracion
char[] data = {0,0,0,0,0,0,0};

int saltos;                    // numero de saltos a usar;
int rx, ex, dx, bx, cx;        // coordenadas x de los botones
int ry, ey, dy, by, cy;        // coordenadas y de los botones
int bsize = 54;                // tamano del boton reset y enviar
int i = 0;
int mensaje = 0;
int mensajer;


boolean rover, eover, dover, bover, cover = false;         // variables que me indican si me encuentro sobre alguno de los botones 
boolean ron, eon, bon, con = false;                        // variables que me indican si alguno de los botones fue presionado
boolean don = true;

color hl, bc;                   // hl = highlight, bc = button color
PImage screen;

byte[] sendb;
byte[] recb;

Serial myPort;                   // Crea un objeto de clase serial

void setup () {

  size (750, 900);               // tamano de la pantalla  
  background(0);                 // fondo color negro
  
  dx = 107;
  bx = 241;
  cx = 375;
  ex = 509;
  rx = 643;
  
  ry = ey = dy = by = cy  = 750;
  
  bc = color(120);
  hl = color(240);
  
  pantalla();
  screen = get(0,0,750,900);
  
  fill(0);
  text("Presione la tecla 'e' para seleccionar la configuracion de esclavo \no 'm' para la de maestro.",60, 75);

  sendb = new byte[5];
  recb = new byte[4];

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.buffer(8);  
  
  }
  
  void draw() { 
  
  fill(0);  
    
  if(control == 4){
    
    image(screen,0,0);
    
    if(don == true)
      text("El mensaje a enviar es: '" +int(data[6])+ "'",60, 75);
    if(bon == true)
      text("El mensaje a enviar es: '" +binary(byte(data[6]))+ "'",60, 75);   
    if(con == true)
      text("El mensaje a enviar es: '" +data[6]+ "'",60, 75);  
    
    if(eon == true){ 
      
      entramado();
      
      myPort.write(sendb[0]);
      myPort.write(sendb[1]); 
      myPort.write(sendb[2]); 
      myPort.write(sendb[3]); 
      myPort.write(sendb[4]);       
 
    } 
  }
  if(control == 5){
  
    mensajer = (recb[0] & 15) << 4;
    mensajer = mensajer | recb[1];
    
    image(screen,0,0);
    
    if(don == true){
      text("El mensaje a enviar es: '" +int(data[6])+ "'",60, 75);
      text("El mensaje recibido es: '" +mensajer+ "'",60, 106);
    }
    if(bon == true){
      text("El mensaje a enviar es: '" +binary(byte(data[6]))+ "'",60, 75);
      text("El mensaje recibido es: '" +binary(byte(mensajer))+ "'",60, 106);
    }
    if(con == true){
      text("El mensaje a enviar es: '" +data[6]+ "'",60, 75);
      text("El mensaje recibido es: '" +char(mensajer)+ "'",60, 106);      
    }
    
    if(eon == true){ 
      
      entramado();
      
      myPort.write(sendb[0]);
      myPort.write(sendb[1]); 
      myPort.write(sendb[2]); 
      myPort.write(sendb[3]); 
      myPort.write(sendb[4]);       
 
    } 
    
  }
  
  if(control == 6){
  
    mensajer = (recb[0] & 15) << 4;
    mensajer = mensajer | recb[1];
    
    image(screen,0,0);
    
    text("Se ha seleccionado la configuracion de esclavo.",60,75);
    
    if(don == true){
      text("El mensaje recibido es: '" +mensajer+ "'",60, 106);
    }
    if(bon == true){
      text("El mensaje recibido es: '" +binary(byte(mensajer))+ "'",60, 106);
    }
    if(con == true){
      text("El mensaje recibido es: '" +char(mensajer)+ "'",60, 106);      
    }
  }        

  if(ron == true){
    image(screen,0,0);
    
    fill(0);
    text("Presione la tecla 'e' para seleccionar la configuracion de esclavo \no 'm' para la de maestro.",60, 75);
    
    control = 0;
    data[0] = data[1] = data[2] = data[3] = data[4] = data[5] = data[6] = 0;
    i = 0;
    ron = false;
  }  
  
  noFill();
    
  estatus();
  estatus_botones();
  eon = false;
}

void entramado() {

  int aux;
  int[] sendbx = new int[5];
  
  sendbx[0] = mensaje >> 4;         
  sendbx[0] = sendbx[0] & 15;         // 15 = 1111 y 128 = 10000000
  sendbx[0] = sendbx[0] | 128;
  sendb[0] = byte(sendbx[0]);

  sendbx[1] = mensaje & 15;
  sendb[1] = byte(sendbx[1]);
  
  aux = (data[2]-48) << 3;
  aux = aux & 56;                    // 56 = 111000;
  sendbx[2] = aux | (data[3]-48);
  sendbx[2] = sendbx[2] & 63;        // 63 = 111111;
  sendb[2] = byte(sendbx[2]);
  
  aux = (data[4]-48) << 3;
  aux = aux & 56;                    // 56 = 111000;
  sendbx[3] = aux | (data[5]-48);
  sendbx[3] = sendbx[3] & 63;        // 63 = 111111;
  sendb[3] = byte(sendbx[3]);
  
  sendbx[4] = (data[1]-48) & 7;      // 7 = 111;
  sendb[4] = byte(sendbx[4]);
}

void keyPressed (){

  tecla = key;
  
  image(screen,0,0);
  
  fill(0);
  
  if (control == 0){
    text("Presione la tecla 'e' para seleccionar la configuracion de esclavo \no 'm' para la de maestro.",60, 75); // \n equivale a una separacion de 31 pixeles en y usando el tamano de letra actual
    text(key,60,137);
    
    if(tecla == 'e' || tecla == 'E'){
    }
    if(tecla == 'm' || tecla == 'M'){
      data[0] = 'M';
      control = 1;
      tecla = 0;
      mensaje = 0;
    }
    if(tecla == 'e' || tecla == 'E'){
      data[0] = 'E';
      control = 6;
      tecla = 0;
      mensaje = 0;
    }    
  }
  
  if (control == 1){
    image(screen,0,0);
    
    text("Se ha seleccionado la configuracion de maestro.",60,75);
    text("Indique el numero de saltos que desea usar (1-4).",60, 106);
    text(tecla,60,137);
    
    if(int(tecla) >= 49 && int(tecla) <= 52){              // 49 es el valor int de '1' y 52 el de '4'
     saltos = int(tecla) - 48;
     control = 2;
     tecla = 0;
    }
  }

  if (control == 2){
    image(screen,0,0);
    text("Se ha elegido " +saltos+ " saltos.",60,75);
    text("Indique la zona a la que se va a mover la torre " +i+ " (1-6).",60, 106);
    text(tecla,60,137);
    
    if(int(tecla) >= 49 && int(tecla) <= 54){              // 48 es el valor int de '1' y 54 el de '6'
       i = i + 1;
       data[i] = tecla;  
       
       if(i-1 == saltos)
         control = 3;     
    }
  }  

  if (control == 3){
    image(screen,0,0);
    text("Se le pedira que seleccione un numero entre 0 - 255,",60,75);
    text("use la tecla '8' para incrementar el valor y '2' para disminuirlo.",60, 106);
    text("Presione la tecla '0' para seleccionar el valor a enviar.",60, 137);
    
   if(tecla == '8')
     mensaje = mensaje + 1;
   if(tecla == '2') 
     mensaje = mensaje - 1;
     
   if(mensaje > 255)
     mensaje = 0;
   if(mensaje < 0)
     mensaje = 255;
     
   text(mensaje,60,168);
   
   if(tecla == '0'){
     control = 4;
     data[6] = char(mensaje);
   }
    
  }   
   
}

void estatus() {

  fill(0);
  
  /*
  rect (330,330,90,40);      //rectángulo Maestro / Esclavo
  rect (50,480,90,40);       //rectángulo Zona 0
  rect (190,480,90,40);      //rectángulo Zona 1
  rect (330,480,90,40);      //rectángulo Zona 2
  rect (470,480,90,40);      //rectángulo Zona 3
  rect (610,480,90,40);      //rectángulo Zona 4
  rect (330,600,90,40);      //rectángulo Mensaje a enviar
  */  
  
  textAlign(CENTER);
  
  text(data[0],375,360);
  text(data[1],95,510);        // zona 0
  text(data[2],235,510);       // zona 1
  text(data[3],375,510);       // zona 2
  text(data[4],515,510);       // zona 3
  text(data[5],655,510);       // zona 4
  text(data[6],375,630);  
  
  textAlign(LEFT);

}

void mousePressed() {

  if (rover) {                  // Comprobacion de que el mouse fue presionado encima del boton de reset
    if(ron == false) {          // Comprobacion que indica si el boton de reset estaba previamente apagado
      ron = true;               // Se activa el boton de reset
    }
  }
 
  if (eover) {                  // Comprobacion de que el mouse fue presionado encima del boton del lidar
    if(eon == false)            // Comprobacion que indica si el boton del lidar estaba previamente apagado
      eon = true;               // Activacion de la muestra de data del lidar
  }  

  if (dover) {                   // Comprobacion de que el mouse fue presionado encima del boton de decimal
    if(don == false) {           // Comprobacion que indica si el boton de decimal estaba previamente apagado
      don = true;                // Se activa el boton de decimal
      bon = false;               // Se activa el boton de binario
      con = false;               // Se activa el boton de char          
    }
  }
  if (bover) {                   // Comprobacion de que el mouse fue presionado encima del boton de decimal
    if(bon == false) {           // Comprobacion que indica si el boton de decimal estaba previamente apagado
      don = false;               // Se activa el boton de decimal
      bon = true;                // Se activa el boton de binario
      con = false;               // Se activa el boton de char          
    }
  }
  if (cover) {                   // Comprobacion de que el mouse fue presionado encima del boton de decimal
    if(con == false) {           // Comprobacion que indica si el boton de decimal estaba previamente apagado
      don = false;               // Se activa el boton de decimal
      bon = false;               // Se activa el boton de binario
      con = true;                // Se activa el boton de char          
    }
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
  
  if(overCircle(rx, ry, bsize)){
    rover = true;
    eover = false;
    dover = false;
    bover = false;
    cover = false;    
  }
  else if(overCircle(ex, ey, bsize)){
    rover = false;
    eover = true;
    dover = false;
    bover = false;
    cover = false; 
  } 
  else if(overCircle(dx, dy, bsize)){
    rover = false;
    eover = false;
    dover = true;
    bover = false;
    cover = false;
  } 
  else if(overCircle(bx, by, bsize)){
    rover = false;
    eover = false;
    dover = false;
    bover = true;
    cover = false;
  } 
  else if(overCircle(cx, cy, bsize)){
    rover = false;
    eover = false;
    dover = false;
    bover = false;
    cover = true;
  }   
  else rover = eover = dover = bover = cover = false;
  
}

void estatus_botones(){

  update(mouseX, mouseY);       // Comprueba el estado de la posicion del puntero respecto a los botones 
  
  // Seccion para el dibujo de los botones
  
  if (rover) {
    fill(hl);
  } else {
    fill(bc);
  }
  stroke(255,0,0);
  ellipse(rx, ry, bsize, bsize);
  
    if (eover) {
    fill(hl);
  } else {
    fill(bc);
  }
  stroke(255,0,0);
  ellipse(ex, ey, bsize, bsize);

  if (dover) {
    fill(hl);
  } else {
    fill(bc);
  }
  stroke(255,0,0);
  ellipse(dx, dy, bsize, bsize);  
  
  if (bover) {
    fill(hl);
  } else {
    fill(bc);
  }
  stroke(255,0,0);
  ellipse(bx, by, bsize, bsize);  
  
  if (cover) {
    fill(hl);
  } else {
    fill(bc);
  }
  stroke(255,0,0);
  ellipse(cx, cy, bsize, bsize);  
  
  noFill();
  noStroke();
  
}

void pantalla() {

  stroke (255,0,0);          //color borde rojo
  strokeWeight (5);          //grosor 5
  fill (0,255,0);            //relleno verde
  rect (50,50,650,200);      //rectángulo
  
  rect (330,330,90,40);      //rectángulo Maestro / Esclavo
  rect (50,480,90,40);       //rectángulo Zona 0
  rect (190,480,90,40);      //rectángulo Zona 1
  rect (330,480,90,40);      //rectángulo Zona 2
  rect (470,480,90,40);      //rectángulo Zona 3
  rect (610,480,90,40);      //rectángulo Zona 4
  rect (330,600,90,40);      //rectángulo Mensaje a enviar
  
  textSize(20);  
  
  fill(#2088C6);
  
  textAlign(LEFT);
  
  text("ER instruments",10,880);
  text("Configuracion:",45,300);
  text("Zonas:",45,450);
  
  textAlign(CENTER);
  
  text("Mensaje Visual",375,30); 
  text("Maestro / Esclavo",375,395);
  text("Zona 0",95,545);
  text("Zona 1",235,545);
  text("Zona 2",375,545);
  text("Zona 3",515,545);
  text("Zona 4",655,545);
  text("Mensaje a enviar",375,665);
  text("Decimal",107,800);
  text("Binario",241,800);
  text("Char",375,800);
  text("Enviar",509,800);
  text("Reset",643,800);
  
  textAlign(LEFT);
  noStroke();
  noFill();
}

void serialEvent(Serial myPort) {

   if ((myPort.available() > 0) && (((control == 4) || (control == 5)) || (control == 6))) {
      do {
        recb[0] = byte(myPort.read());
      } while (int(recb[0]) < 128);
      recb[1] = byte(myPort.read());
      recb[2] = byte(myPort.read());
      recb[3] = byte(myPort.read());
      
      myPort.clear();
      
      print("Data enviada:  "+binary(sendb[0])+ " " +binary(sendb[1])+ " " +binary(sendb[2])+ " " +binary(sendb[3])+ "\n");
      print("Data recibida: "+binary(recb[0])+ " " +binary(recb[1])+ " " +binary(recb[2])+ " " +binary(recb[3])+ "\n\n");
      
      if(control == 4)
        control = 5;
 } 
  
}
