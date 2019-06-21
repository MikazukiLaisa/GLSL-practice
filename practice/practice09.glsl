#ifdef GL_ES
precision mediump float;
#endif

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float sdBox(vec3 p, vec3 s){
	p = abs(p) - s;
	return max(max(p.x, p.y), p.z);
}

vec3 foldX(vec3 p){
	p.x = abs(p.x);
	return p;
}

mat2 rotate(float a){
	float s = sin(a);
	float c = cos(a);
	return mat2(c, s, -s, c);
}

vec2 foldRotate(in vec2 p, in float s){
    float a = 3.14 / s - atan(p.x, p.y);
    float n = 3.14 / s;
    a = floor(a / n) * n;
    p *= rotate(a);
    return p;
}

float sdTree(vec3 p){
    float scale = 0.6 * saturate(1.5 * sin(0.05 * time));
    float width = mix(0.3 * scale, 0.0, saturate(p.y));
	vec3 size = vec3(width, 1.0, width);
	//変な向きのBOX
	float d = sdBox(p, size);
    for(int i = 0; i < 10; i++){
        vec3 q = p;
        q.x = abs(q.x);
        q.y -= 0.5 * size.y;
        q.xy *= rotate(-1.2);
        d = min(d, sdBox(p, size));
        p = q;
        size *= scale;
    }
	return d;
}

float sdSnowCrystal(inout vec3 p){
    p.xy = foldRotate(p.xy, 6.0);
    return sdTree(p);
}

//-----------------------------------------------//
float distScene(vec3 p){
	return sdTree(p);
}

const float EPS = 0.01;
vec3 getNormal(vec3 p){
	return normalize(vec3(
		distScene(p+vec3(EPS, 0.0, 0.0)) - distScene(p + vec3(-EPS, 0.0, 0.0)),
		distScene(p+vec3(0.0, EPS, 0.0)) - distScene(p + vec3(0.0, -EPS, 0.0)),
		distScene(p+vec3(0.0, 0.0, EPS)) - distScene(p + vec3(0.0, 0.0, -EPS))
	));
}



void main( void ) {
	vec2 p = (gl_FragCoord.xy * 2. - resolution.xy) / (min(resolution.x, resolution.y));
	vec3 cameraPos = vec3(0.,0.,-5);
	float screenZ = 2.5;
	vec3 rayDirection = normalize(vec3(p,screenZ));
	vec3 lightDir = normalize(vec3(1.,1.,-1));

	float depth = 0.0;
	vec3 color = vec3(0.0);
	float diffuse = 0.;
	vec3 normal = vec3(0.,0.,0.);

	for(int i= 0; i < 99; i++){
		vec3 rayPos = cameraPos + rayDirection * depth;
		float dist = distScene(rayPos);

		if(dist < 0.0001){
			normal = getNormal(rayPos);
			diffuse = clamp(dot(lightDir, rayPos), 0.1, 1.0);
			color = vec3(1.0);
			break;
		}

		depth += dist;
	}

	color = color * diffuse;
	gl_FragColor = vec4(color, 1.0);
}