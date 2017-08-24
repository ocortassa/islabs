package it.unito.di.islabs.engine;

public class RegisterThread extends Thread {
	private Object object;

	public RegisterThread(Object ob) {
		object = ob;
		start();
	}

	public void run() {
//		System.gc(); // Richiamo forzato del garbage collector
		object = null;
	}
}