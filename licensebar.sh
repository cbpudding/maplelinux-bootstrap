#!/bin/sh -e
# Usage: ./licensebar.sh > licensebar.svg
# Yes, this is cursed, but it was the simplest way I could think of automating this. ~ahill
COPYLEFT_COUNT=$(grep "| Copyleft  " SOFTWARE.md | wc -l)
SLIGHTLY_COPYLEFT_COUNT=$(grep "| Slightly Copyleft  " SOFTWARE.md | wc -l)
FREE_COUNT=$(grep "| Free  " SOFTWARE.md | wc -l)
MIXED_COUNT=$(grep "| Mixed  " SOFTWARE.md | wc -l)
SLIGHTLY_COPYRIGHT_COUNT=$(grep "| Slightly Copyright |" SOFTWARE.md | wc -l)
COPYRIGHT_COUNT=$(grep "| Copyright  " SOFTWARE.md | wc -l)

BAR_BORDER=3
BAR_HEIGHT=16
BAR_TOTAL=$(expr $COPYLEFT_COUNT + $SLIGHTLY_COPYLEFT_COUNT + $FREE_COUNT + $MIXED_COUNT + $SLIGHTLY_COPYRIGHT_COUNT + $COPYRIGHT_COUNT)
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

render_segment blue $COPYLEFT_COUNT
render_segment cornflowerblue $SLIGHTLY_COPYLEFT_COUNT
render_segment white $FREE_COUNT
render_segment mediumpurple $MIXED_COUNT
render_segment indianred $SLIGHTLY_COPYRIGHT_COUNT
render_segment crimson $COPYRIGHT_COUNT

echo "</svg>"
