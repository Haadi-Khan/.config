from i3ipc import Connection, Event

i3 = Connection()

focused = i3.get_tree().find_focused().workspace().num

out = ""
colors = [
    # Blue
    "%{F#61afef}",
    "%{F#61afef}",
    # Red
    "%{F#e06c75}",
    "%{F#e06c75}",
    # Green
    "%{F#98c379}",
    "%{F#98c379}",
    # Yellow
    "%{F#e5c07b}",
    "%{F#e5c07b}",
    # Magenta
    "%{F#c678dd}",
    "%{F#c678dd}"
]

for i in range(1, 11):
    if focused % 2 == 1 and i == focused:
        out += colors[i-1]
    if i % 2 == 1:
        out += "%{F-}"
    out+= " "
print(out)
