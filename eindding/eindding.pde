import processing.sound.*;

SoundFile geluid;

PImage player, enemy, kogel1, kogel2;

int x = 200;
int y = 500;
int snelheid = 4;

int hp = 5;
int frame = 1;
int frameTeller = 0;
int onkwetsbaarTijd = 0;

boolean boven, onder, links, rechts;
boolean gameOver = false;
boolean geluidGeladen = false;

ArrayList<Kogel> kogels = new ArrayList<Kogel>();

void setup() {
  size(600, 770);

  player = loadImage("player.jpeg");
  enemy = loadImage("enemy.jpg");
  kogel1 = loadImage("kogel1.png");
  kogel2 = loadImage("kogel2.png");

  try {
    geluid = new SoundFile(this, "hit.mp3");
    geluidGeladen = true;
  } catch (Exception e) {
    println("Audio laden mislukt: " + e.getMessage());
  }
}

void draw() {
  background(0);

  image(enemy, 180, 100, 200, 200);

  noFill();
  stroke(255);
  strokeWeight(2);
  rect(100, 320, 360, 360);

  if (gameOver) {
    fill(255);
    textAlign(CENTER);
    textSize(40);
    text(". . .", 280, 380);
    tekenHPBar();
    return;
  }

  if (boven) y -= snelheid;
  if (onder) y += snelheid;
  if (links) x -= snelheid;
  if (rechts) x += snelheid;

  x = constrain(x, 110, 420);
  y = constrain(y, 330, 640);

  if (onkwetsbaarTijd > 0) {
    onkwetsbaarTijd--;
  }

  if (onkwetsbaarTijd == 0 || frameCount % 6 < 3) {
    image(player, x, y, 30, 30);
  }

  tekenHPBar();

  frameTeller++;

  if (frameTeller >= 4) {
    frame = 3 - frame;
    frameTeller = 0;
  }

  if (frameCount % 60 == 0) {
    if (random(1) < 0.7) {
      int aantal = (int) random(1, 3);

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
      onkwetsbaarTijd = 60;

      if (hp <= 0) {
        hp = 0;
        gameOver = true;
        kogels.clear();
        break;
      }
    }

    if (k.weg()) {
      kogels.remove(i);
    }
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
    kx = startX;
    ky = startY;
    richting = 0;
  }

  Kogel(int startX, int startY, int startRichting) {
    kx = startX;
    ky = startY;
    richting = startRichting;
  }

  void beweeg() {
    if (richting == 1) {
      kx += 6;
    } else if (richting == 2) {
      kx -= 6;
    } else if (!gesplitst) {
      ky += 8;

      if (ky >= 450) {
        linksX = kx;
        linksY = ky;
        rechtsX = kx;
        rechtsY = ky;
        gesplitst = true;
      }
    } else {
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
    if (richting != 0 || !gesplitst) {
      return dist(kx, ky, x + 15, y + 15) < 35;
    }

    return dist(linksX, linksY, x + 15, y + 15) < 35 ||
           dist(rechtsX, rechtsY, x + 15, y + 15) < 35;
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

  if ((key == 'f' || key == 'F') && geluidGeladen) {
    geluid.stop();
    geluid.play();
  }

  if ((key == 'r' || key == 'R') && gameOver) {
    x = 200;
    y = 500;
    hp = 5;
    onkwetsbaarTijd = 0;
    kogels.clear();
    gameOver = false;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') boven = false;
  if (key == 's' || key == 'S') onder = false;
  if (key == 'a' || key == 'A') links = false;
  if (key == 'd' || key == 'D') rechts = false;
}
