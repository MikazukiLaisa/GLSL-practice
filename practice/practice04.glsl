#ifdef GL_ES
precision mediump float;
#endif

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

mat2 rotate2d(float angle){
    return mat2(
        cos(angle),-sin(angle),
        sin(angle),cos(angle));
}

float distSphere(vec3 p){
	float d = length(p) - 1.;
	return d;
}

float distBox(vec3 p, float s){
    p = abs(p) - s;
    return max(max(p.x, p.y), p.z);
}

float distBox2(vec3 p, float size, vec3 offset){
    p = p - offset;
    p = abs(p) - size;
    return max(max(p.x, p.y), p.z);
}

//-----------------------------------------------//
float distScene(vec3 p){
	p.xz = rotate2d(time) * p.xz;
	return min(
        distBox2(p, .5, vec3(0.,1.,0.)),
        distBox2(p, .3, vec3(0.,0.,0.))
        );
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
	vec3 color = vec3(.0);
	float diffuse = 0.;
	vec3 normal = vec3(0.,0.,0.);

	for(int i= 0; i < 99; i++){
		vec3 rayPos = cameraPos + rayDirection * depth;
		float dist = distScene(rayPos);

		if(dist < 0.0001){
			normal = getNormal(rayPos);
			diffuse = clamp(dot(lightDir, rayPos), 0.1, 1.0);
			color = min(vec3(0.,1.,0.), vec3(1.,0.3,0.3));
        	color = color * diffuse;
			break;
		}

		depth += dist;
	}

	gl_FragColor = vec4(color, 1.);
}