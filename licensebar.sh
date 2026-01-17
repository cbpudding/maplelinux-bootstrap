#!/bin/sh -e
# Usage: ./licensebar.sh <copyleft count> <slightly copyleft count> <free count> <mixed count> <slightly copyright count> <copyright count>
# Yes, this is cursed, but it was the simplest way I could think of automating this. ~ahill
BAR_BORDER=3
BAR_HEIGHT=16
BAR_TOTAL=$(expr $1 + $2 + $3 + $4 + $5 + $6)
BAR_WIDTH=1024

BAR_END=$(expr $BAR_WIDTH - $BAR_BORDER)
BAR_INNER=$(expr $BAR_WIDTH - \( 2 \* $BAR_BORDER \))
BAR_OFFSET=$BAR_BORDER

render_segment() {
    size=$(printf %.0f $(echo "($BAR_INNER / $BAR_TOTAL) * $2" | bc -l))
    echo "<rect fill=\"$1\" height=\"$(expr $BAR_HEIGHT - \( 2 \* $BAR_BORDER \))\" width=\"$size\" x=\"$BAR_OFFSET\" y=\"$BAR_BORDER\" />"
    BAR_OFFSET=$(expr $BAR_OFFSET + $size)
}

echo "<svg height=\"$BAR_HEIGHT\" version=\"1.1\" width=\"$BAR_WIDTH\" xmlns=\"http://www.w3.org/2000/svg\">"
echo "<rect fill=\"black\" height=\"100%\" width=\"100%\" />"

render_segment blue $1
render_segment cornflowerblue $2
render_segment white $3
render_segment mediumpurple $4
render_segment indianred $5
render_segment crimson $6

echo "</svg>"
