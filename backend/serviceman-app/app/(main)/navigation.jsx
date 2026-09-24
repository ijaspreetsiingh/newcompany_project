import { useEffect, useState, useRef } from 'react';
import { View, StyleSheet, Dimensions, Platform, TouchableOpacity, Linking, Animated } from 'react-native';
import { Text, Button, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';
import MapView, { Marker, Polyline, PROVIDER_DEFAULT } from 'react-native-maps';
import * as Location from 'expo-location';
import { configService } from '../../src/api';
import { COLORS, iOS, TYPOGRAPHY } from '../../src/theme/theme';

const { width, height } = Dimensions.get('window');
const OSRM_BASE = 'https://router.project-osrm.org';

export default function NavigationScreen() {
  const router = useRouter();
  const { destLat, destLng, address, bookingId } = useLocalSearchParams();
  const mapRef = useRef(null);
  const slideAnim = useRef(new Animated.Value(0)).current;

  const [currentLocation, setCurrentLocation] = useState(null);
  const [routeCoords, setRouteCoords] = useState([]);
  const [routeInfo, setRouteInfo] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [tracking, setTracking] = useState(false);
  const [isNavigating, setIsNavigating] = useState(false);
  const locationSubscription = useRef(null);

  const destination = {
    latitude: parseFloat(destLat) || 0,
    longitude: parseFloat(destLng) || 0,
  };

  useEffect(() => {
    Animated.timing(slideAnim, {
      toValue: 1,
      duration: iOS.animation.normal,
      useNativeDriver: true,
    }).start();
  }, []);

  useEffect(() => {
    startLocationTracking();
    return () => {
      if (locationSubscription.current) {
        locationSubscription.current.remove();
      }
    };
  }, []);

  useEffect(() => {
    if (currentLocation && destination.latitude && destination.longitude) {
      fetchRoute();
      fitMapToMarkers();
    }
  }, [currentLocation]);

  const startLocationTracking = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') {
      setError('Location permission denied');
      setIsLoading(false);
      return;
    }

    const loc = await Location.getCurrentPositionAsync({
      accuracy: Location.Accuracy.High,
    });
    setCurrentLocation({
      latitude: loc.coords.latitude,
      longitude: loc.coords.longitude,
    });
    setIsLoading(false);

    locationSubscription.current = await Location.watchPositionAsync(
      {
        accuracy: Location.Accuracy.High,
        timeInterval: 3000,
        distanceInterval: 5,
      },
      (newLocation) => {
        const newCoords = {
          latitude: newLocation.coords.latitude,
          longitude: newLocation.coords.longitude,
        };
        setCurrentLocation(newCoords);
        if (isNavigating) {
          fetchRoute();
        }
      }
    );
  };

  const fetchRoute = async () => {
    try {
      const originLat = currentLocation.latitude;
      const originLng = currentLocation.longitude;
      const destLatNum = destination.latitude;
      const destLngNum = destination.longitude;

      const url = `${OSRM_BASE}/route/v1/driving/${originLng},${originLat};${destLngNum},${destLatNum}?overview=full&geometries=geojson&steps=true`;

      const response = await fetch(url);
      const data = await response.json();

      if (data.routes && data.routes.length > 0) {
        const route = data.routes[0];
        const coords = route.geometry.coordinates.map((coord) => ({
          latitude: coord[1],
          longitude: coord[0],
        }));

        setRouteCoords(coords);

        const distanceMeters = route.distance;
        const durationSeconds = route.duration;

        let distanceText;
        if (distanceMeters >= 1000) {
          distanceText = (distanceMeters / 1000).toFixed(1) + ' km';
        } else {
          distanceText = Math.round(distanceMeters) + ' m';
        }

        let durationText;
        const durationMinutes = Math.round(durationSeconds / 60);
        if (durationMinutes >= 60) {
          const hours = Math.floor(durationMinutes / 60);
          const mins = durationMinutes % 60;
          durationText = `${hours} hr ${mins} min`;
        } else {
          durationText = `${durationMinutes} min`;
        }

        setRouteInfo({
          distance: distanceText,
          duration: durationText,
          distanceValue: distanceMeters,
          durationValue: durationSeconds,
        });
      }
    } catch (err) {
      console.log('Route fetch error:', err);
      setError('Failed to fetch route');
    }
  };

  const fitMapToMarkers = () => {
    if (!mapRef.current || !currentLocation) return;

    const coordinates = [
      currentLocation,
      destination,
    ];

    mapRef.current.fitToCoordinates(coordinates, {
      edgePadding: { top: 120, right: 60, bottom: 280, left: 60 },
      animated: true,
    });
  };

  const toggleNavigation = () => {
    setIsNavigating(!isNavigating);
    if (!isNavigating) {
      fitMapToMarkers();
    }
  };

  const openInGoogleMaps = () => {
    const url = `https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destination.latitude},${destination.longitude}&mode=d`;
    Linking.openURL(url);
  };

  if (isLoading) {
    return (
      <View style={styles.loaderContainer}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={styles.loaderText}>Getting your location...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Ionicons name="alert-circle" size={48} color={COLORS.error} />
        <Text style={styles.errorTitle}>Location Error</Text>
        <Text style={styles.errorText}>{error}</Text>
        <Button mode="contained" onPress={() => router.back()} style={styles.errorButton}>
          Go Back
        </Button>
      </View>
    );
  }

  const slideStyle = {
    transform: [{
      translateY: slideAnim.interpolate({
        inputRange: [0, 1],
        outputRange: [100, 0],
      }),
    }],
  };

  return (
    <View style={styles.container}>
      {/* Map */}
      <MapView
        ref={mapRef}
        style={styles.map}
        provider={PROVIDER_DEFAULT}
        initialRegion={{
          latitude: currentLocation?.latitude || destination.latitude,
          longitude: currentLocation?.longitude || destination.longitude,
          latitudeDelta: 0.05,
          longitudeDelta: 0.05,
        }}
        showsUserLocation={true}
        showsMyLocationButton={false}
        showsCompass={true}
        followsUserLocation={isNavigating}
      >
        {/* Current Location Marker */}
        {currentLocation && (
          <Marker
            coordinate={currentLocation}
            title="Your Location"
            description="You are here"
          >
            <View style={styles.currentMarker}>
              <View style={styles.currentMarkerPulse} />
              <View style={styles.currentMarkerDot} />
            </View>
          </Marker>
        )}

        {/* Destination Marker */}
        <Marker
          coordinate={destination}
          title="Client Location"
          description={address || 'Service address'}
        >
          <View style={styles.destMarker}>
            <View style={styles.destMarkerBg}>
              <Ionicons name="location" size={24} color={COLORS.white} />
            </View>
            <View style={styles.destMarkerShadow} />
          </View>
        </Marker>

        {/* Route Polyline */}
        {routeCoords.length > 0 && (
          <Polyline
            coordinates={routeCoords}
            strokeColor={COLORS.mapRoute}
            strokeWidth={5}
            lineCap="round"
            lineJoin="round"
          />
        )}
      </MapView>

      {/* Top Controls */}
      <View style={styles.topControls}>
        <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
          <Ionicons name="chevron-back" size={24} color={COLORS.textPrimary} />
        </TouchableOpacity>
        
        <TouchableOpacity
          style={[styles.navToggleBtn, isNavigating && styles.navToggleBtnActive]}
          onPress={toggleNavigation}
        >
          <Ionicons 
            name={isNavigating ? 'navigate' : 'navigate-outline'} 
            size={24} 
            color={isNavigating ? COLORS.white : COLORS.primary} 
          />
        </TouchableOpacity>
      </View>

      {/* Recenter Button */}
      <TouchableOpacity
        style={styles.recenterButton}
        onPress={fitMapToMarkers}
      >
        <Ionicons name="compass" size={22} color={COLORS.primary} />
      </TouchableOpacity>

      {/* Bottom Info Panel */}
      <Animated.View style={[styles.infoPanel, slideStyle]}>
        <View style={styles.panelHandle} />

        {/* Route Info */}
        <View style={styles.routeInfoRow}>
          <View style={styles.routeInfoItem}>
            <View style={[styles.routeIconBg, { backgroundColor: COLORS.infoAlpha }]}>
              <Ionicons name="navigate" size={20} color={COLORS.info} />
            </View>
            <View style={styles.routeInfoText}>
              <Text style={styles.routeInfoLabel}>Distance</Text>
              <Text style={styles.routeInfoValue}>{routeInfo?.distance || 'Calculating...'}</Text>
            </View>
          </View>
          <View style={styles.routeInfoDivider} />
          <View style={styles.routeInfoItem}>
            <View style={[styles.routeIconBg, { backgroundColor: COLORS.warningAlpha }]}>
              <Ionicons name="time" size={20} color={COLORS.warning} />
            </View>
            <View style={styles.routeInfoText}>
              <Text style={styles.routeInfoLabel}>ETA</Text>
              <Text style={styles.routeInfoValue}>{routeInfo?.duration || 'Calculating...'}</Text>
            </View>
          </View>
        </View>

        {/* Destination Info */}
        <View style={styles.destinationInfo}>
          <View style={[styles.destIconBg, { backgroundColor: COLORS.errorAlpha }]}>
            <Ionicons name="location" size={18} color={COLORS.error} />
          </View>
          <View style={styles.destTextContainer}>
            <Text style={styles.destLabel}>Destination</Text>
            <Text style={styles.destText} numberOfLines={2}>
              {address || 'Service location'}
            </Text>
          </View>
        </View>

        {/* Action Buttons */}
        <View style={styles.actionButtons}>
          <Button
            mode="contained"
            icon="google"
            onPress={openInGoogleMaps}
            style={styles.navButton}
            contentStyle={styles.navButtonContent}
            labelStyle={styles.navButtonLabel}
            buttonColor={COLORS.primary}
          >
            Open in Google Maps
          </Button>
          <Button
            mode="outlined"
            onPress={() => router.back()}
            style={styles.backButtonBottom}
            contentStyle={styles.backButtonBottomContent}
            labelStyle={styles.backButtonBottomLabel}
          >
            Back to Booking
          </Button>
        </View>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  map: {
    flex: 1,
  },
  loaderContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  loaderText: {
    marginTop: iOS.spacing.lg,
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
    paddingHorizontal: iOS.spacing.xxl,
  },
  errorTitle: {
    fontSize: TYPOGRAPHY.fontSize.xxl,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
    marginTop: iOS.spacing.lg,
  },
  errorText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    marginTop: iOS.spacing.sm,
    textAlign: 'center',
  },
  errorButton: {
    marginTop: iOS.spacing.xl,
    borderRadius: iOS.borderRadius.lg,
  },
  topControls: {
    position: 'absolute',
    top: Platform.OS === 'ios' ? 60 : 40,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: iOS.screenPadding.horizontal,
  },
  backButton: {
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.lg,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowMedium,
  },
  navToggleBtn: {
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.lg,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowMedium,
  },
  navToggleBtnActive: {
    backgroundColor: COLORS.primary,
  },
  recenterButton: {
    position: 'absolute',
    top: Platform.OS === 'ios' ? 120 : 100,
    right: iOS.screenPadding.horizontal,
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.lg,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowMedium,
  },
  currentMarker: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  currentMarkerPulse: {
    position: 'absolute',
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.primaryAlpha,
    borderWidth: 2,
    borderColor: COLORS.primary,
  },
  currentMarkerDot: {
    width: 16,
    height: 16,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.primary,
    borderWidth: 3,
    borderColor: COLORS.white,
  },
  destMarker: {
    alignItems: 'center',
  },
  destMarkerBg: {
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.error,
    justifyContent: 'center',
    alignItems: 'center',
  },
  destMarkerShadow: {
    position: 'absolute',
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.errorAlpha,
  },
  infoPanel: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: COLORS.surface,
    borderTopLeftRadius: iOS.borderRadius.xxxl,
    borderTopRightRadius: iOS.borderRadius.xxxl,
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingBottom: Platform.OS === 'ios' ? 34 : 20,
    paddingTop: iOS.spacing.lg,
    ...iOS.shadowXLarge,
  },
  panelHandle: {
    width: 40,
    height: 4,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.separator,
    alignSelf: 'center',
    marginBottom: iOS.spacing.lg,
  },
  routeInfoRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: COLORS.background,
    borderRadius: iOS.borderRadius.xl,
    padding: iOS.spacing.lg,
    marginBottom: iOS.spacing.lg,
  },
  routeInfoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.md,
    flex: 1,
  },
  routeIconBg: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  routeInfoText: {
    flex: 1,
  },
  routeInfoLabel: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.xs,
  },
  routeInfoValue: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  routeInfoDivider: {
    width: 1,
    height: 40,
    backgroundColor: COLORS.separator,
    marginHorizontal: iOS.spacing.lg,
  },
  destinationInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.md,
    marginBottom: iOS.spacing.xl,
    paddingHorizontal: iOS.spacing.sm,
  },
  destIconBg: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  destTextContainer: {
    flex: 1,
  },
  destLabel: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.xs,
  },
  destText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textPrimary,
    lineHeight: TYPOGRAPHY.lineHeight.normal,
  },
  actionButtons: {
    gap: iOS.spacing.md,
  },
  navButton: {
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    ...iOS.shadowMedium,
  },
  navButtonContent: {
    height: iOS.height.button,
  },
  navButtonLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  backButtonBottom: {
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    borderColor: COLORS.separator,
  },
  backButtonBottomContent: {
    height: iOS.height.button,
  },
  backButtonBottomLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
});
