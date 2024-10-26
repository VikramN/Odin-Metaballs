package main
import "core:math"
import "core:mem"
import "core:fmt"
import ray "vendor:raylib"

SCREEN_WIDTH  :: 800
SCREEN_HEIGHT :: 600

Metaball :: [3]f32

// Random wrapper around ray's random
Random::proc(min, max : f32) -> f32 {
    return f32(ray.GetRandomValue(i32(min), i32(max)))
}

// Gen a random metaball
Generate :: proc() -> Metaball {
    size := Random(10, 30)
    p := ray.Vector2 { Random(size, SCREEN_WIDTH - size), Random(size, SCREEN_HEIGHT - size)  }
    return [3]f32{ p.x, p.y, size }
}

// Move and keep in bounds
Update :: proc(self : ^Metaball, vel : ^ray.Vector2, elapsed : f32)  {
    self.x += vel.x * elapsed;
    self.y += vel.y * elapsed;

    if self.x >= SCREEN_WIDTH {
        vel.x = -1.0 * abs(vel.x)
    } else if self.x < 0.0 {
        vel.x = abs(vel.x)
    }

    if self.y >= SCREEN_HEIGHT {
        vel.y = -1.0 * abs(vel.y)
    } else if self.y < 0.0 {
        vel.y = abs(vel.y)
    }
}

// Let shader know the new ball positions
UpdateShader::proc(shader : ^ray.Shader, balls : ^[dynamic]Metaball) {
    
    l := i32(len(balls))    

    // t := mem.slice_data_cast([]f32 , balls^)    // Ideally send this to shader?

    ray.SetShaderValueV(
        shader^, 
        ray.GetShaderLocation(shader^, "balls"),         
        raw_data(balls^), 
        ray.ShaderUniformDataType.VEC3, l)
    
    ray.SetShaderValue(
        shader^, 
        ray.GetShaderLocation(shader^, "ballCount"), 
        &l, ray.ShaderUniformDataType.INT)    
}


main::proc() {

    ray.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Metaballs")
	defer ray.CloseWindow() 
    
    // Load metaball shader
    shader := ray.LoadShader(nil, "shader.frag")
    defer ray.UnloadShader(shader)

    balls := make_dynamic_array([dynamic]Metaball)
    velocities := make_dynamic_array([dynamic]ray.Vector2)

    // Start with 5
    count := 5
    for i in 0..<count {       
        append(&balls, Generate())
        append(&velocities, ray.Vector2{ Random(1, 100), Random(1, 100), })
    }

    // Let shader know screen size
    ray.SetShaderValue(
        shader, 
        ray.GetShaderLocation(shader, "screen"), 
        &[2]f32 { f32(SCREEN_WIDTH), f32(SCREEN_HEIGHT) }, 
        .VEC2)

    for !ray.WindowShouldClose() {

        elapsed := ray.GetFrameTime();

        for &b, index in balls {
            Update(&b, &velocities[index], elapsed)
        }

        if ray.IsMouseButtonReleased(ray.MouseButton.LEFT) && count < 30 {
            p := ray.GetMousePosition()

            b := Generate()
            b.x = p.x
            b.y = p.y

            append(&balls, b)
            append(&velocities, ray.Vector2{ Random(1, 100), Random(1, 100), })
            count += 1
        }

        UpdateShader(&shader, &balls)

		ray.BeginDrawing()
		defer ray.EndDrawing()

        ray.BeginShaderMode(shader)
        ray.DrawRectangle(0, 0 , SCREEN_WIDTH, SCREEN_HEIGHT, ray.WHITE)
        ray.EndShaderMode()
       
        ray.DrawText("LEFT-CLICK to ADD", 10, SCREEN_HEIGHT - 50, 22, ray.RED)
        ray.DrawFPS(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 50)
        
	}
}