using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CameraEffect : MonoBehaviour
{
    [Header("控制器")]
    public Transform target;
    public float xSpeed = 200;
    public float ySpeed = 200;
    public float mSpeed = 10;
    float yMinLimit = -50;
    float yMaxLimit = 50;
    float distance = 3;
    public float minDistance = 2;
    public float maxDistance = 30;
    public bool needDamping = true;
    float damping = 5.0f;
    float x = 0.0f;
    float y = 0.0f;

    [Header("后期效果")]
    [Range(0f,1f)]
    public float aoStrength = 0f; 
    [Range(4, 64)]
    public int SampleKernelCount = 64;
    private List<Vector4> sampleKernelList = new List<Vector4>();
    [Range(0.0001f,10f)]
    public float sampleKernelRadius = 0.01f;
    [Range(0.0001f,0.001f)]
    public float rangeStrength = 0.001f;
    public float depthBiasValue;
    public Texture Nosie;//噪声贴图
    [Range(0, 2)]
    public int DownSample = 0;
    [Range(1, 4)]
    public int BlurRadius = 2;
    [Range(0, 0.2f)]
    public float bilaterFilterStrength = 0.2f;
    public bool OnlyShowAO = false;

    public enum SSAOPassName
    {
        GenerateAO = 0,
        BilateralFilter = 1,
        Composite = 2,
    }
    Material render;
    Camera cam;

    void Awake(){
        var shader=Shader.Find("Yif/SSAO");
        render=new Material(shader);
    }

    void Start()
    {
        Vector3 angles = transform.eulerAngles;
        x = angles.y;
        y = angles.x;

        // 将相机深度纹理模式调整为带深度和法线信息供shader使用
        cam = this.GetComponent<Camera>();
        cam.depthTextureMode|=DepthTextureMode.DepthNormals;

    }

    void LateUpdate()
    {
        if (target)
        {
            if (Input.GetMouseButton(0))
            {
                x += Input.GetAxis("Mouse X") * xSpeed * 0.02f;
                y -= Input.GetAxis("Mouse Y") * ySpeed * 0.02f;
                y = ClampAngle(y, yMinLimit, yMaxLimit);
            }
            distance -= Input.GetAxis("Mouse ScrollWheel") * mSpeed;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);
            Quaternion rotation = Quaternion.Euler(y, x, 0.0f);
            Vector3 disVector = new Vector3(0.0f, 0.0f, -distance);
            Vector3 position = rotation * disVector + target.position;
            //adjust the camera 
            if (needDamping)
            {
                transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * damping);
                transform.position = Vector3.Lerp(transform.position, position, Time.deltaTime * damping);
            }
            else
            {
                transform.rotation = rotation;
                transform.position = position;
            }
        }
    }
    static float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360)
            angle += 360;
        if (angle > 360)
            angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        GenerateAOSampleKernel();
        int rtW = source.width >> DownSample;
        int rtH = source.height >> DownSample;

        //AO
        RenderTexture aoRT = RenderTexture.GetTemporary(rtW,rtH,0);
        render.SetVectorArray("_SampleKernelArray", sampleKernelList.ToArray());
        render.SetFloat("_RangeStrength", rangeStrength);
        render.SetFloat("_AOStrength", aoStrength);
        render.SetFloat("_SampleKernelCount", sampleKernelList.Count);
        render.SetFloat("_SampleKernelRadius",sampleKernelRadius);
        render.SetFloat("_DepthBiasValue",depthBiasValue);
        render.SetTexture("_NoiseTex", Nosie);
        Graphics.Blit(source, aoRT, render,(int)SSAOPassName.GenerateAO);
        //Blur
        RenderTexture blurRT = RenderTexture.GetTemporary(rtW,rtH,0);
        render.SetFloat("_BilaterFilterFactor", 1.0f - bilaterFilterStrength);
        render.SetVector("_BlurRadius", new Vector4(BlurRadius, 0, 0, 0));
        Graphics.Blit(aoRT, blurRT, render, (int)SSAOPassName.BilateralFilter);

        render.SetVector("_BlurRadius", new Vector4(0, BlurRadius, 0, 0));
        if (OnlyShowAO)
        {
            Graphics.Blit(blurRT, destination, render, (int)SSAOPassName.BilateralFilter);
        }
        else
        {
            Graphics.Blit(blurRT, aoRT, render, (int)SSAOPassName.BilateralFilter);
            render.SetTexture("_AOTex", aoRT);
            Graphics.Blit(source, destination, render, (int)SSAOPassName.Composite);
        }

        RenderTexture.ReleaseTemporary(aoRT);
        RenderTexture.ReleaseTemporary(blurRT);
    }

    private void GenerateAOSampleKernel()
    {
        if (SampleKernelCount == sampleKernelList.Count)
            return;
        sampleKernelList.Clear();
        for (int i = 0; i < SampleKernelCount; i++)
        {
            var vec = new Vector4(Random.Range(-1.0f, 1.0f), Random.Range(-1.0f, 1.0f), Random.Range(0, 1.0f), 1.0f);
            vec.Normalize();
            var scale = (float)i / SampleKernelCount;
            scale = Mathf.Lerp(0.01f, 1.0f, scale * scale);
            vec *= scale;
            sampleKernelList.Add(vec);
        }
    }

}