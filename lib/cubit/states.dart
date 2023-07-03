abstract class MainStates {}

class InitialState extends MainStates {}

class InitialYouTubeClientState extends MainStates {}

class GetVideoMetaDataSuccessState extends MainStates {}

class GetVideoMetaDataErrorState extends MainStates {}

class GetVideoMetaDataLoadingState extends MainStates {}

class GetVideoManifestSuccessState extends MainStates {}

class GetVideoManifestErrorState extends MainStates {}

class GetVideoManifestLoadingState extends MainStates {}

class DownloadVideoLoadingsState extends MainStates {}

class DownloadVideoSuccessState extends MainStates {}

class DownloadVideoErrorState extends MainStates {}

class Videoing extends MainStates {}

class VideoingPlayin extends MainStates {}

class PauseVideo extends MainStates {}

class ChangeCurrentIndexState extends MainStates {}

class GetCachedVideosState extends MainStates {}

class GetThumnailsSuccess extends MainStates {}

class GetThumnailsError extends MainStates {}

class FileDeletedState extends MainStates {}

class ClearSearchItemState extends MainStates {}

class ProgressUpadateState extends MainStates {}

class GetAudioCachesSuccess extends MainStates {}

class DownloadAudioSucces extends MainStates {}
