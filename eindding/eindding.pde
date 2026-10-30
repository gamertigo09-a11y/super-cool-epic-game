PImage player, enemy, kogel1, kogel2;

int x = 270, y = 480;
int snelheid = 4;
int hp = 5;
int frame = 1;
int frameTeller = 0;
int onkwetsbaarTijd = 0;

int startTijd;
int seconden;

boolean boven, onder, links, rechts;
boolean gameOver = false;

ArrayList<Kogel> kogels = new ArrayList<Kogel>();

void setup() {
  size(600, 770);

  player = loadImage("player.jpeg");
  enemy = loadImage("enemy.jpg");
  kogel1 = loadImage("kogel1.png");
  kogel2 = loadImage("kogel2.png");

  startTijd = millis();
}

void draw() {
  background(0);
  image(enemy, 180, 100, 200, 200);

  noFill();
  stroke(255);
  strokeWeight(2);
  rect(100, 320, 360, 360);

  if (!gameOver) {
    seconden = (millis() - startTijd) / 1000;
  }

  fill(255);
  textSize(20);
  textAlign(LEFT);
  text(nf(seconden / 60, 2) + ":" + nf(seconden % 60, 2), 110, 305);

  if (gameOver) {
    fill(255);
    textAlign(CENTER);
    textSize(40);
    // >        <  doodtekst
    text(". . .", 280, 380);
    tekenHPBar();
    return;
  }
// speler speed          > "+    " <
  if (boven) y -= snelheid + 2;
  if (onder) y += snelheid + 2;
  if (links) x -= snelheid + 2;
  if (rechts) x += snelheid + 2;

  x = constrain(x, 110, 420);
  y = constrain(y, 330, 640);

  if (onkwetsbaarTijd > 0) onkwetsbaarTijd--;

  if (onkwetsbaarTijd == 0 || frameCount % 6 < 3) {
    image(player, x, y, 30, 30);
  }

  tekenHPBar();

  frameTeller++;
  if (frameTeller >= 4) {
    frame = 3 - frame;
    frameTeller = 0;
  }

//schiet snelheid >  <
  if (frameCount % 60 == 0) {
    if (random(1) < 0.7) {
      // kogel hoeveelheid     >     <
      int aantal = (int) random(1, 5);

      for (int i = 0; i < aantal; i++) {
        kogels.add(new Kogel((int) random(120, 440), 250));
      }
    } else {
      kogels.add(new Kogel(-30, (int) random(350, 650), 1));
      kogels.add(new Kogel(490, (int) random(350, 650), 2));
    }
  }

  for (int i = kogels.size() - 1; i >= 0; i--) {
    Kogel k = kogels.get(i);

    k.beweeg();
    k.teken();

    if (k.raaktSpeler() && onkwetsbaarTijd == 0) {
      hp--;
      //freeframe      >   <
      onkwetsbaarTijd = 40;

      if (hp <= 0) {
        hp = 0;
        gameOver = true;
        kogels.clear();
        break;
      }
    }

    if (k.weg()) kogels.remove(i);
  }
}

void tekenHPBar() {
  noStroke();
  fill(0);
  rect(150, 730, 260, 20);

  fill(255, 255, 0);
  rect(150, 730, 260 * hp / 5.0, 20);

  stroke(255);
  noFill();
  rect(150, 730, 260, 20);
}

void tekenKogel(int kx, int ky) {
  if (frame == 1) {
    image(kogel1, kx - 50, ky - 50, 45, 45);
  } else {
    image(kogel2, kx - 50, ky - 50, 45, 45);
  }
}

class Kogel {
  int kx, ky;
  int linksX, linksY, rechtsX, rechtsY;
  int richting;
  boolean gesplitst = false;

  Kogel(int startX, int startY) {
    this(startX, startY, 0);
  }

  Kogel(int startX, int startY, int startRichting) {
    kx = startX;
    ky = startY;
    richting = startRichting;
  }

  // snelheid kogel
  void beweeg() {
    if (richting == 1) {
      //   >  <
      kx += 6;
    } else if (richting == 2) {
      //   >  <
      kx -= 6;
    } else if (!gesplitst) {
      //   >  <
      ky += 8;

      if (ky >= 450) {
        linksX = rechtsX = kx;
        linksY = rechtsY = ky;
        gesplitst = true;
      }
    } else {
      //       >   <
      linksX -= 3;
      linksY += 4;
      rechtsX += 3;
      rechtsY += 4;
    }
  }

  void teken() {
    if (richting != 0 || !gesplitst) {
      tekenKogel(kx, ky);
    } else {
      tekenKogel(linksX, linksY);
      tekenKogel(rechtsX, rechtsY);
    }
  }

boolean raaktSpeler() {
  if (richting != 0) {
    return kogelRaakt(kx, ky);
  }

  if (!gesplitst) {
    return kogelRaakt(kx, ky);
  }

  return kogelRaakt(linksX, linksY) ||
         kogelRaakt(rechtsX, rechtsY);
}

boolean kogelRaakt(int kogelX, int kogelY) {
  float kogelLinks = kogelX - 50;
  float kogelBoven = kogelY - 50;
  float spelerRechts = x + 30;
  float spelerOnder = y + 30;

  return kogelLinks + 45 > x &&
         kogelLinks < spelerRechts &&
         kogelBoven + 45 > y &&
         kogelBoven < spelerOnder;
}


  boolean weg() {
    if (richting != 0) {
      return kx < -100 || kx > width + 100;
    }

    if (gesplitst) {
      return linksY > 800 && rechtsY > 800;
    }

    return ky > 800;
  }
}

void keyPressed() {
  if (key == 'w' || key == 'W') boven = true;
  if (key == 's' || key == 'S') onder = true;
  if (key == 'a' || key == 'A') links = true;
  if (key == 'd' || key == 'D') rechts = true;

  if (key == 'f' || key == 'F') {


  }

  if ((key == 'r' || key == 'R') && gameOver) {
    x = 270;
    y = 480;
    hp = 5;
    onkwetsbaarTijd = 0;
    kogels.clear();
    seconden = 0;
    startTijd = millis();
    gameOver = false;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') boven = false;
  if (key == 's' || key == 'S') onder = false;
  if (key == 'a' || key == 'A') links = false;
  if (key == 'd' || key == 'D') rechts = false;
}
