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
    float n = 6.28 / s;
    a = floor(a / n) * n;
    p *= rotate(a);
    return p;
}

#define onRep(p, interval) (mod(p, interval) - 0.5 * interval)
#define onRepLimit(p, interval, limit) (mod(clamp(p, -limit, limit), interval) - 0.5 * interval);

float sdWing(in vec3 p){
    float t = time;
    float l = length(p.xz);
    float fusion = gauss(time * 2.0);

    float a = 0.1 + 0.06 *(1.0 + sin(3.14 * t + l));
    float b = min(0.2 * t, 10.0) * gauss(l) + 0.1 * fusion * hWave(p.xz, t);
    p.y += -b + 15.0;
    
    vec3 p1 = p;
    p1.xz = onRepLimit(p.xz, 1.0, 20.0);

    vec3 p2 = p;
    p2 = onRep(p, 0.5);

    float d = sdBox(p1, vec3(0.2 + a * 3.0, 12.0 - a, 0.2 +a));
    d = min(d, sdBox(p1, vec3(0.4 - a, 13.0 - 4.0 * a, 0.1 + a)));
    d = max(d, -sdBox(p1, vec3(0.3 - a, 14.0 - 4.0 * a, a)));
    d = max(d, -sdBox(p2, vec3(0.8 * a, 1.0 - a, 0.8 * a)));
    return d;
}

float sdUfo(inout vec3 p){
    float t = max(time * 0.5, 1.0);
    float t1 = floor(t);
    float t2 = t1 + easeInOutCubic(t, -t1);

    p.xz = foldRotate(p.xz, min(t2, 10.0));
    p.z -= 0.5;
    float d = sdWing(p);
    return d;
}

float sdTree(vec3 p){
    float scale = 0.6 * saturate(1.5 * sin(0.05 * time));
    float width = mix(0.3 * scale, 0.0, saturate(p.y));
	vec3 size = vec3(width, 1.0, width);
	//変な向きのBOX
	float d = sdBox(p, size);
    for(int i = 0; i < 100; i++){
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
	return sdUfo(p);
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
	vec3 lightDir = normalize(vec3(1.,1.,-2.0));

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