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

vec2 onRep(vec2 p, float interval){
    return mod(p,interval) - interval * 0.5;
}

float distBar(vec2 p,float interval, float width){
    return length(max(abs(onRep(p,interval)) - width, 0.));
}

float distTube(vec2 p, float interval, float width){
    return length(onRep(p, interval)) - width;
}


//-----------------------------------------------//
float distScene(vec3 p){
	float bar_x = distBar(p.yz,1., 0.1);
    float bar_y = distBar(p.xz,1., 0.1);
    float bar_z = distBar(p.xy,1., 0.1);

    float tube_x = distTube(p.yz, 0.1, 0.025);
    float tube_y = distTube(p.xz, 0.1, 0.025);
    float tube_z = distTube(p.xy, 0.1, 0.025);
    return max(max(max(min(min(bar_x, bar_y), bar_z), -tube_x), -tube_y), -tube_z);
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
	
	vec3 cameraPos = vec3(0.,0.,-5.);
	float screenZ = 2.5;
	vec3 rayDirection = normalize(vec3(p,screenZ));
	vec3 lightDir = normalize(vec3(2,0.,-0.3));

	float depth = 0.0;
	vec3 color = vec3(0.0);
	float diffuse = 0.;
	vec3 normal = vec3(0.,0.,0.);

	for(int i= 0; i < 99; i++){
		vec3 rayPos = cameraPos + rayDirection * depth;
		float dist = distScene(rayPos);

		if(dist < 0.0001){
			normal = getNormal(rayPos);
			lightDir.xz = rotate2d(time) * lightDir.xz;
			diffuse = clamp(dot(lightDir, rayPos), 0.1, .9);
			color = vec3(1.);
			break;
		}

		depth += dist;
	}

	color = color * diffuse;
	gl_FragColor = vec4(color, 1.);
}