CC = marp
THEMES = ./theme
FLAGS= --allow-local-files --theme-set $(THEMES)

CMD = $(CC) $(FLAGS)

pdf: deck.md
	$(CMD) --pdf $^ 
