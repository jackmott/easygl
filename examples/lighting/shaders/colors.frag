#version 330 core
out vec4 FragColor;
  
uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    vec3 ambient = 0.1 * lightColor;
    FragColor = vec4(ambient * objectColor, 1.0);
}
