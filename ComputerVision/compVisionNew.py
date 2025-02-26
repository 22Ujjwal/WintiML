import cv2
import numpy as np
import mediapipe as mp
from deepface import DeepFace

target_emotions = ['angry', 'sad', 'neutral', 'happy']

mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(static_image_mode=False, min_detection_confidence=0.5)

def analyze_emotions(image: np.ndarray) -> str:
    try:
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        result = DeepFace.analyze(rgb_image, actions=['emotion'], enforce_detection=False)
        detected_emotion = result[0]['dominant_emotion'].lower()
        return detected_emotion
    except Exception as e:
        print(f"Error in emotion analysis: {str(e)}")
        return "unknown"

def draw_vectors(image, points, indices):
    for i in range(len(indices) - 1):
        p1 = points[indices[i]]
        p2 = points[indices[i + 1]]
        cv2.line(image, p1, p2, (255, 0, 0), 1)

def main():
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("Error: Could not open webcam.")
        return
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(rgb_frame)
        
        if results.multi_face_landmarks:
            for face_landmarks in results.multi_face_landmarks:
                points = []
                for landmark in face_landmarks.landmark:
                    x = int(landmark.x * frame.shape[1])
                    y = int(landmark.y * frame.shape[0])
                    points.append((x, y))
                    cv2.circle(frame, (x, y), 2, (255, 0, 0), -1)
                
                EYE_INDICES = [33, 133, 362, 263, 7, 8, 9, 10, 226, 445]
                LIP_INDICES = [61, 185, 40, 39, 37, 267, 269, 270, 409]
                FACE_EDGES = [1, 4, 234, 454, 152]
                
                draw_vectors(frame, points, EYE_INDICES)
                draw_vectors(frame, points, LIP_INDICES)
                draw_vectors(frame, points, FACE_EDGES)
        
        emotion = analyze_emotions(frame)
        
        # Define color based on emotion
        color = {
            'happy': (0, 255, 0),    # Green
            'sad': (255, 0, 0),      # Blue
            'angry': (0, 0, 255),    # Red
            'neutral': (255, 255, 0), # Cyan
            'unknown': (128, 128, 128) # Gray
        }.get(emotion, (255, 255, 255))
        
        # Display emotion text with color
        cv2.putText(frame, f"Emotion: {emotion.capitalize()}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)
        
        cv2.imshow('Webcam Face Analysis', frame)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()