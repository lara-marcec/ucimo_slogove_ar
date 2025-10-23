using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class PrefabLoader : MonoBehaviour
{
    [SerializeField]
    private ARTrackedImageManager trackedImageManager;

    [Tooltip("Folder inside Resources (e.g., 'ARPrefabs')")]
    [SerializeField]
    private string prefabFolder = "ARPrefabs";

    private List<GameObject> loadedPrefabs = new List<GameObject>();
    private bool hasSpawned = false;

    void Awake()
    {
        Object[] prefabs = Resources.LoadAll(prefabFolder, typeof(GameObject));
        foreach (Object obj in prefabs)
        {
            loadedPrefabs.Add(obj as GameObject);
        }

        if (loadedPrefabs.Count == 0)
        {
            Debug.LogError("No prefabs found in Resources/" + prefabFolder);
        }
    }

    void OnEnable()
    {
        trackedImageManager.trackedImagesChanged += OnTrackedImagesChanged;
    }

    void OnDisable()
    {
        trackedImageManager.trackedImagesChanged -= OnTrackedImagesChanged;
    }

    private void OnTrackedImagesChanged(ARTrackedImagesChangedEventArgs eventArgs)
    {
        if (hasSpawned || loadedPrefabs.Count == 0) return;

        foreach (ARTrackedImage trackedImage in eventArgs.added)
        {
            SpawnRandomPrefab(trackedImage);
            hasSpawned = true;
        }
    }

    private void SpawnRandomPrefab(ARTrackedImage trackedImage)
    {
        int index = Random.Range(0, loadedPrefabs.Count);
        GameObject prefab = loadedPrefabs[index];

        GameObject instance = Instantiate(prefab, trackedImage.transform.position, trackedImage.transform.rotation);
        instance.transform.parent = trackedImage.transform; // Optional: attach to image

        Debug.Log($"Spawned random prefab: {prefab.name}");
    }
}
