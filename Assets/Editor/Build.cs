using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Build
{
    public static void BuildAndroid()
    {
        BuildPlayerOptions opts = new BuildPlayerOptions();
        opts.locationPathName = "LearnShader.apk";
        opts.scenes = new[] { "Assets/Scenes/SampleScene.unity" };
        opts.target = BuildTarget.Android;
        opts.options = BuildOptions.None;
        BuildPipeline.BuildPlayer(opts);
    }


}
