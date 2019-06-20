#ifdef GL_ES
precision mediump float;
#endif

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float sdBox(vec3 p, float s){
    return p.y;
}

float sdBox2(vec3 p, float s){
    return p.x;
}

float sdBox3(vec3 p, float s){
    p = p -s;
    return max(max(p.x, p.y), p.z);
}

vec2 foldX(vec2 p){
    p.x = abs(p.x);
    return p;
}

float sdBox4(vec3 p, float s){
    p = abs(p) - s;
    return max(max(p.x, p.y), p.z);
}

void main(void){
    vec2 p = (gl_FragCoord.xy * 2. - resolution.xy) / min(resolution.x, resolution.y);
    gl_FragColor = vec4(p,0.0,1.0);


}