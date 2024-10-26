#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform vec2 screen;
uniform vec3 balls[50];
uniform int ballCount;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables

void main()
{   
    float d = 0.0;
    
    for (int i = 0; i < ballCount; i++) {
        vec3 ball = balls[i];   
        vec2 p = ball.xy;
        p.y = screen.y -p.y;
        d += ball.z / distance(gl_FragCoord.xy, p) * 50.0;
    }

    float u = step(100.0, d) * 200.0 / 255.0;
    finalColor = vec4(u, u, u ,1.0);
}

