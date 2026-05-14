using TMPro;
using UnityEngine;
using UnityEngine.Playables;

public class TMPStringClip : PlayableAsset
{
    public ExposedReference<TextMeshProUGUI> targetText;
    public string displayText;
    [Header("Typewriter")]
    public float charInterval = 0.05f;     // 1•¶Žš‚ ‚½‚è
    public float punctuationWait = 0.2f;   // ‹å“Ç“_‘Ò‹@
    public ExposedReference<TMPStringDisplayController> controller;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<TMPStringDisplay>.Create(graph);

        var behaviour = playable.GetBehaviour();

        behaviour.textMeshProUGUI =
            targetText.Resolve(graph.GetResolver());

        behaviour.displayText = displayText;
        behaviour.charInterval = charInterval;
        behaviour.punctuationWait = punctuationWait;

        behaviour.controller =
        controller.Resolve(graph.GetResolver());

        return playable;
    }
}