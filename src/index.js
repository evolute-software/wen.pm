'use strict';

require('../elm/index.html');
require('./particles.min.js')
import './style.scss';
var Elm = require('../elm/src/Main.elm').Elm;

var app = Elm.Main.init({flags: []});



// Particles  ////////////////////////////////////////////////////////////////
particlesJS("particles-js", {
  particles: {
    number: { value: 80, density: { enable: true, value_area: 800 } },
    color: { value: "#9f0313" },
    shape: {
      type: "polygon",
      stroke: { width: 0, color: "#725050" },
      polygon: { nb_sides: 5 },
      //image: { src: "img/github.svg", width: 100, height: 100 }
    },
    opacity: {
      value: 1,
      random: false,
      anim: { enable: false, speed: 0.6, opacity_min: 0.1, sync: false }
    },
    size: {
      value: 3,
      random: true,
      anim: { enable: false, speed: 20, size_min: 0.1, sync: false }
    },
    line_linked: {
      enable: true,
      distance: 250,
      color: "#df1030",
      opacity: 0.4,
      width: 1
    },
    move: {
      enable: true,
      speed: 2,
      direction: "none",
      random: false,
      straight: false,
      out_mode: "out",
      bounce: false,
      attract: { enable: false, rotateX: 600, rotateY: 1200 }
    }
  },
  
  retina_detect: true
});

