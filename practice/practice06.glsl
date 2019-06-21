#ifdef GL_ES
precision mediump float;
#endif

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float dBox(vec2 p, vec2 s){
    return max(abs(p.x) - s.x, abs(p.y) - s.y);
}

float dCharG(vec2 p){
    p *= 2.;
    float d = dBox(p, vec2(.25, 1.));
    d = min(d, dBox(p - vec2(0.75, 0.75), vec2(1.0, 0.25)));
    d = min(d, dBox(p - vec2(0.75, -0.75), vec2(1.0, 0.25)));
    d = min(d, dBox(p - vec2(1.5, -0.5), vec2(0.25, 0.5)));
    d = min(d, dBox(p - vec2(1.25, 0.0), vec2(0.5, 0.125)));
    return d;
}

vec2 foldX(vec2 p) {
 	p.x = abs(p.x);
	return p;
}

void main(void){
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
    p = foldX(p);
    p -= vec2(0.4, 0.0);
    float color = sign(dCharG(p));

    gl_FragColor = vec4(vec3(color), 1.0);
}