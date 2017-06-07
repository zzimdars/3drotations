import toxi.audio.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.data.csv.*;
import toxi.data.feeds.*;
import toxi.data.feeds.util.*;
import toxi.doap.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh2d.*;
import toxi.geom.nurbs.*;
import toxi.image.util.*;
import toxi.math.*;
import toxi.math.conversion.*;
import toxi.math.noise.*;
import toxi.math.waves.*;
import toxi.music.*;
import toxi.music.scale.*;
import toxi.net.*;
import toxi.newmesh.*;
import toxi.nio.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;
import toxi.physics3d.*;
import toxi.physics3d.behaviors.*;
import toxi.physics3d.constraints.*;
import toxi.processing.*;
import toxi.sim.automata.*;
import toxi.sim.dla.*;
import toxi.sim.erosion.*;
import toxi.sim.fluids.*;
import toxi.sim.grayscott.*;
import toxi.util.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.volume.*;

Vec3D hori = new Vec3D(1,0,0);
Vec3D vert = new Vec3D(0,1,0);
Vec3D out = new Vec3D(0,0,1);
Vec3D m;
Vec3D axis;
float theta;

PImage img;
ArrayList<Taurus> ts;


void setup() {
  size(800,800,P3D);
  //img = loadImage("Hibbs_Matt.jpg");
  img = loadImage("pattern.jpg");
  ts = new ArrayList<Taurus>();
  
  for(int i = 0; i < 5; i++) {
    Taurus t = new Taurus(30,16,img);
    ts.add(t);
  }
  translate(width/2, height/2, 0);  
  pushMatrix();
}


void draw() {
  popMatrix();
  background(0);
  strokeWeight(2);
  stroke(0,255,0);
  line(-width/2, 0, 0, width/2, 0,0);
  stroke(255,0,0);
  line(0, -height/2, 0, 0, height/2, 0);
  stroke(255,255,255);
  line(0,0,-width, 0, 0, width);
  
  stroke(255,255,0);
  line(-hori.x*1000, -hori.y*1000, -hori.z*1000, hori.x*1000, hori.y*1000, hori.z*1000);
  stroke(128,128,128);
  line(-vert.x*1000, -vert.y*1000, -vert.z*1000, vert.x*1000, vert.y*1000, vert.z*1000);
  stroke(0,255,255);
  line(-out.x*1000, -out.y*1000, -out.z*1000, out.x*1000, out.y*1000, out.z*1000);
  
  
  pointLight(255,255,255, out.x*1000, out.y*1000, out.z*750);//hori, vert.magnitude()*(mouseY*2), out.magnitude()*1000);
  //lightSpecular(255,255,255);
  specular(255,255,255);
  
  //box(100); 
  for(int i = 0; i < ts.size(); i++) {
    ts.get(i).display();
    rotateX(TWO_PI/ts.size());
  }
  
  
  pushMatrix();
}

void mouseDragged() {
  popMatrix();
  m = new Vec3D(hori.scale(mouseX - pmouseX).add(vert.scale(mouseY - pmouseY)));
  axis = new Vec3D(m.cross(out).normalize());

  
  theta = m.magnitude()/(float)width*2;
  //print("axis: " + axis + "\n");
  //print("theta: " + theta + "\n");
  //print("hori: " + hori + "\n");
  //print("vert: " + vert + "\n");
  //print("out: " + out + "\n");
  //m.rotateAroundAxis(axis, theta);
  rotateAroundAxis(axis, -theta);
  hori = rotateAroundAxis(axis, -theta, hori).normalize();
  vert = rotateAroundAxis(axis, -theta, vert).normalize();
  out = rotateAroundAxis(axis, -theta, out).normalize();
  pushMatrix();
}

Vec3D rotateAroundAxis(Vec3D axis, float theta, Vec3D vec) {
  Vec3D w = new Vec3D(axis);
  w.normalize();
  Vec3D t = new Vec3D(w);
  if (w.x - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.x = 1;
  } else if (w.y - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.y = 1;
  } else if (w.z - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.z = 1;
  } else {
    println("Minimum not found -- screw you floating point numbers");
  }
  Vec3D u = w.cross(t);
  u.normalize();
  Vec3D v = w.cross(u);
  Vec3D res = new Vec3D(vec);
  res = new Vec3D(u.x*res.x + u.y*res.y + u.z*res.z,
                    v.x*res.x + v.y*res.y + v.z*res.z,
                    w.x*res.x + w.y*res.y + w.z*res.z);
  res = new Vec3D(cos(theta)*res.x + sin(theta)*res.y,
                    -sin(theta)*res.x + cos(theta)*res.y, res.z);
  res = new Vec3D(u.x*res.x + v.x*res.y + w.x*res.z,
                    u.y*res.x + v.y*res.y + w.y*res.z,
                    u.z*res.x + v.z*res.y + w.z*res.z);
  return res;
}

void rotateAroundAxis(Vec3D axis, float theta) {
  Vec3D w = new Vec3D(axis);
  w.normalize();
  Vec3D t = new Vec3D(w);
  if (abs(w.x) - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.x = 1;
  } else if (abs(w.y) - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.y = 1;
  } else if (abs(w.z) - min(abs(w.x), abs(w.y), abs(w.z)) < 0.001) {
    t.z = 1;
  }
  Vec3D u = w.cross(t);
  u.normalize();
  Vec3D v = w.cross(u);
  applyMatrix(u.x, v.x, w.x, 0, 
  u.y, v.y, w.y, 0, 
  u.z, v.z, w.z, 0, 
  0.0, 0.0, 0.0, 1);
  rotateZ(theta);
  applyMatrix(u.x, u.y, u.z, 0, 
  v.x, v.y, v.z, 0, 
  w.x, w.y, w.z, 0, 
  0.0, 0.0, 0.0, 1);
}