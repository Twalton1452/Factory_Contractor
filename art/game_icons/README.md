# Game Icons

## Current Approach
The game is using a Spritesheet for all of the icons.  
The game is also using a data-driven approach, meaning all of the Components are stored in Resource files.  
So the most maintainable way to deal with displaying icons at the moment is to create separate resources that hold the coordinates to the texture in the Spritesheet (`AtlasTexture`).  
This means we can swap out the Resource files holding the coordinates at any time and it will not break references or require tons of manual labor to replace the icons.
