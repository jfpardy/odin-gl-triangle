package main

import "core:fmt"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"


//Const set up
	WINDOW_WIDTH  :: 854
	WINDOW_HEIGHT :: 480

    GL_VERSION_MAJOR :: 4
    GL_VERSION_MINOR :: 6

//shader source
    vertex_source :cstring =`#version 330 core
    layout (location = 0) in vec3 aPos;
    void main()
    {
       gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    }`; 

    fragment_source:cstring = `#version 330 core
    out vec4 FragColor;
    void main()
    {
       FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    }`;



main :: proc() {
//initialise glfw
    glfw.Init()
    defer glfw.Terminate()

    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_VERSION_MAJOR)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_VERSION_MINOR)
    glfw.WindowHint(glfw.OPENGL_PROFILE,glfw.OPENGL_CORE_PROFILE)
    window_handle :glfw.WindowHandle= glfw.CreateWindow(WINDOW_WIDTH,WINDOW_HEIGHT,"Hello Window", nil,nil)
    if (window_handle == nil){
    fmt.eprint("Failed to create glfw window! \n")
        }
    glfw.MakeContextCurrent(window_handle);
    glfw.SwapInterval(0);
    glfw.SetFramebufferSizeCallback(window_handle,frame_buffer_size_callback)
  //OpenGL set up
    gl.load_up_to(GL_VERSION_MAJOR, GL_VERSION_MINOR, proc(p: rawptr, name: cstring) {
		(^rawptr)(p)^ = glfw.GetProcAddress(name);
	});

    gl.Viewport(0,0,WINDOW_WIDTH,WINDOW_HEIGHT);
    //Shader set up
    fragmentShader,vertexShader: u32;
    vertexShader = gl.CreateShader(gl.VERTEX_SHADER)
    fragmentShader = gl.CreateShader(gl.FRAGMENT_SHADER)

    gl.ShaderSource(vertexShader,1,&vertex_source,nil)
    gl.ShaderSource(fragmentShader,1,&fragment_source,nil)
    gl.CompileShader(vertexShader)
    gl.CompileShader(fragmentShader)
    

    shader_success: i32;
    shader_program : u32;
    shader_program = gl.CreateProgram();
    gl.AttachShader(shader_program,vertexShader);
    gl.AttachShader(shader_program,fragmentShader);
    gl.LinkProgram(shader_program);
    //Delete shaders after linking
    gl.DeleteShader(vertexShader)
    gl.DeleteShader(fragmentShader)

    gl.GetProgramiv(shader_program,gl.LINK_STATUS,&shader_success)
    if (shader_success == 0){
        fmt.eprintln("SHADER ERROR")
        return
    }

    vertices :=[?]f32{0.0,0.5, 0.0,
                  -0.5, -0.5, 0.0,
                  0.5, -0.5, 0.0,
             }

    VAO: u32;
    gl.GenVertexArrays(1,&VAO);
    gl.BindVertexArray(VAO);


    VBO : u32;
    gl.GenBuffers(1,&VBO);
    
    gl.BindBuffer(gl.ARRAY_BUFFER,VBO)
    gl.BufferData(gl.ARRAY_BUFFER,size_of(vertices),&vertices,gl.STATIC_DRAW)
    gl.VertexAttribPointer(0,3,gl.FLOAT,gl.FALSE, size_of(f32)*3, cast(uintptr)0)
    gl.EnableVertexAttribArray(0)
    gl.UseProgram(shader_program);
    for (!glfw.WindowShouldClose(window_handle)){
        process_input(window_handle);
        glfw.PollEvents();
        gl.ClearColor(0.2,0.3,0.3,1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.UseProgram(shader_program);
        gl.BindVertexArray(VAO);
        gl.DrawArrays(gl.TRIANGLES,0,3);

        glfw.SwapBuffers(window_handle);
    }

}

frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width,height :i32){
    gl.Viewport(0,0,width,height);
}


process_input:: proc(window: glfw.WindowHandle){
    if(glfw.GetKey(window,glfw.KEY_ESCAPE) == glfw.PRESS){
        glfw.SetWindowShouldClose(window, true)
    }
    if(glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS){
     gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);
    }

    if(glfw.GetKey(window, glfw.KEY_F) == glfw.PRESS){
     gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL);
    }
}


