
moaiBase = new Moai.Base ();

MoaiModule = null;

function moduleDidLoad() {
  MoaiModule = document.getElementById('moai');
  //MoaiModule.addEventListener('message', handleMessage, false);
  MoaiModule.addEventListener('message', moaiBase.naclMessageHandler, false);
}

function pageDidLoad() {
}

document.getElementById('listener').addEventListener('load', moduleDidLoad, true);
