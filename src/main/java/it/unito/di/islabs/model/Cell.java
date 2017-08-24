package it.unito.di.islabs.model;

public class Cell {
	private int row;
	private int column;
	private String type;

	public Cell(int r, int c, String t) {
		row = r;
		column = c;
		type = t;
	}

	public int getRow()
	{
		return row;
	}

	public int getColumn()
	{
		return column;
	}

	public String getType()
	{
		return type;
	}

}
