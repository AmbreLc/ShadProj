using UnityEngine;
using System.Collections;

public class OrbitalCam : MonoBehaviour {
	float Horizangle=0;
	float Verticangle=0;
	public float Distance=5;
	Vector2 OldMousePos;
	float OldDistanceZoom=0;
	bool MouseClicked=false;
	bool DoubleTouch=false;
	bool ThreeTouch=false;
	Vector2 OldThreePos;
	public Camera Kamera;
	bool OldTouchdistance=false;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		#if UNITY_ANDROID||UNITY_IPHONE



		if (Input.touchCount==0)
		{
			MouseClicked=false;
			DoubleTouch=false;
			ThreeTouch=false;
		}
		if (Input.touchCount==1)
		{
			if (!MouseClicked)
			{
				OldMousePos=Input.GetTouch(0).position;
				MouseClicked=true;
			}
			Horizangle+=0.005f*(Input.GetTouch(0).position.x-OldMousePos.x);
			Verticangle-=0.005f*(Input.GetTouch(0).position.y-OldMousePos.y);
			if (Verticangle>1.5f) Verticangle=1.5f;
			if (Verticangle<-1.5f) Verticangle=-1.5f;
			DoubleTouch=false;
			ThreeTouch=false;
			OldMousePos=Input.GetTouch(0).position;
		}
		if (Input.touchCount==2)
		{
			MouseClicked=false;
			ThreeTouch=false;
			if (!DoubleTouch)
			{
				OldDistanceZoom=(Input.GetTouch(0).position-Input.GetTouch(1).position).magnitude;
				DoubleTouch=true;
			}
			Distance*=1+0.005f*(OldDistanceZoom-(Input.GetTouch(0).position-Input.GetTouch(1).position).magnitude);
			OldDistanceZoom=(Input.GetTouch(0).position-Input.GetTouch(1).position).magnitude;
		}
		if (Input.touchCount==3)
		{
			MouseClicked=false;
			DoubleTouch=false;
			if (!ThreeTouch)
			{
				OldThreePos=(Input.GetTouch(0).position+Input.GetTouch(1).position+Input.GetTouch(2).position)/3.0f;
				ThreeTouch=true;
			}
			transform.position-=0.002f*Distance*Kamera.transform.right*(((Input.GetTouch(0).position+Input.GetTouch(1).position+Input.GetTouch(2).position)/3.0f)-OldThreePos).x;
			transform.position-=0.002f*Distance*Kamera.transform.up*(((Input.GetTouch(0).position+Input.GetTouch(1).position+Input.GetTouch(2).position)/3.0f)-OldThreePos).y;

			OldThreePos=(Input.GetTouch(0).position+Input.GetTouch(1).position+Input.GetTouch(2).position)/3.0f;
		}
#endif
		#if UNITY_EDITOR||UNITY_STANDALONE_OSX||UNITY_STANDALONE_WIN||UNITY_STANDALONE_LINUX||UNITY_WEBPLAYER
		if (Input.GetMouseButtonDown(0))
		{
			OldMousePos=Input.mousePosition;
			MouseClicked=true;
		}
		if (Input.GetMouseButtonUp(0))
		{
			MouseClicked=false;
		}
		
		if (MouseClicked) 
		{
			if (Input.GetKey(KeyCode.LeftShift))
			{
				transform.position-=0.003f*Distance*Kamera.transform.right*(Input.mousePosition.x-OldMousePos.x);
				transform.position-=0.003f*Distance*Kamera.transform.up*(Input.mousePosition.y-OldMousePos.y);

			}
			else
			{
				Horizangle+=0.01f*(Input.mousePosition.x-OldMousePos.x);
				Verticangle-=0.01f*(Input.mousePosition.y-OldMousePos.y);
				if (Verticangle>1.5f) Verticangle=1.5f;
				if (Verticangle<-1.5f) Verticangle=-1.5f;
			}
			OldMousePos=Input.mousePosition;
		}
		
		Distance*=1-1.5f*(Input.GetAxis("Mouse ScrollWheel"));




#endif
		Kamera.transform.localPosition=Distance*(new Vector3(Mathf.Sin (Horizangle)* Mathf.Cos(Verticangle),Mathf.Sin (Verticangle),Mathf.Cos(Horizangle)* Mathf.Cos(Verticangle)));
		Kamera.transform.LookAt(transform.position);
	}
}
