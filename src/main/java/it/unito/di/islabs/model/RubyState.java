package it.unito.di.islabs.model;

import java.util.ArrayList;
import java.util.List;

public class RubyState {
	private boolean loaded;
	private int r;
	private int c;
	private String direction;
	private int visited;
	private static List<Cell> unusefulCells = new ArrayList<Cell>();

	public RubyState() {/*empty*/}

	public RubyState(int r, int c, String d, boolean l) {
		this.r = r;
		this.c = c;
		direction = d;
		loaded = l;
	}

	public void setPosition(int r, int c) {
		this.r = r;
		this.c = c;
	}

	public void setLoaded(boolean l)
	{
		loaded = l;
	}

	public void setDirection(String d)
	{
		direction = d;
	}

	public int getPositionX()
	{
		return r;
	}

	public int getPositionY()
	{
		return c;
	}

	public boolean getLoaded()
	{
		return loaded;
	}

	public String getDirection()
	{
		return direction;
	}

	public void setVisited(int v)
	{
		visited = v;
	}

	public int getVisited()
	{
		return visited;
	}

	public void addUnusefulCell(int r, int c) {
		Cell x = new Cell(r, c, "Unuseful");
		unusefulCells.add(x);
	}

	public static void eraseUnusefulCells()
	{
		unusefulCells.clear();
	}

	public List<Cell> getUnusefulCells()
	{
		return unusefulCells;
	}

}