using TMPro;
using UnityEngine;
using UnityEngine.Playables;

public class TMPStringClip : PlayableAsset
{
    public ExposedReference<TextMeshProUGUI> targetText;
    public string displayText;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<TMPStringDisplay>.Create(graph);

        var behaviour = playable.GetBehaviour();

        behaviour.textMeshProUGUI =
            targetText.Resolve(graph.GetResolver());

        behaviour.displayText = displayText;

        return playable;
    }
}