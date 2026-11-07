import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity, Alert, ActivityIndicator } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { apiClient } from '../../api/client';
import { Card } from '../../components/Card';
import { Button } from '../../components/Button';
import { Badge } from '../../components/Badge';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const PassengerHomeScreen = ({ navigation }: any) => {
  const { user, switchRole } = useAuth();
  const [rides, setRides] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [joiningRideId, setJoiningRideId] = useState<string | null>(null);

  // Default coordinate: Antalya Bilim University area
  const userLat = 36.8848;
  const userLng = 30.7040;

  const fetchRides = async () => {
    setLoading(true);
    try {
      const res: any = await apiClient.get(`/rides/search?lat=${userLat}&lng=${userLng}&radius_km=10`);
      setRides(res.data || []);
    } catch (e: any) {
      console.warn('Ride search failed', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRides();
  }, []);

  const handleJoinRide = async (rideId: string) => {
    setJoiningRideId(rideId);
    try {
      await apiClient.post(`/rides/${rideId}/join`);
      Alert.alert(
        'Talebiniz İletildi 🚀',
        'Şoför talebinizi onayladığında ekranda biniş QR kodunuz belirecektir.',
        [{ text: 'Tamam', onPress: fetchRides }]
      );
    } catch (error: any) {
      Alert.alert('Katılım Hatası', error.message || 'Talebiniz gönderilemedi.');
    } finally {
      setJoiningRideId(null);
    }
  };

  return (
    <View style={styles.container}>
      {/* Role Switcher Bar */}
      <View style={styles.topHeader}>
        <View style={styles.roleToggleBox}>
          <TouchableOpacity
            style={[styles.roleBtn, styles.roleBtnActive]}
            onPress={() => switchRole('yolcu')}
          >
            <Text style={styles.roleTextActive}>🚶‍♂️ Yolcu Modu</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.roleBtn}
            onPress={() => switchRole('sofor')}
          >
            <Text style={styles.roleText}>🚗 Şoför Modu</Text>
          </TouchableOpacity>
        </View>

        {user?.is_premium && (
          <View style={styles.premiumPill}>
            <Text style={styles.premiumText}>⭐ Premium (Öncelikli)</Text>
          </View>
        )}
      </View>

      {/* Map Banner Placeholder */}
      <View style={styles.mapCard}>
        <Text style={styles.mapTitle}>🗺️ Antalya Kampüs Koridoru</Text>
        <Text style={styles.mapSub}>Yakınınızdaki 10 km içerisindeki aktif yolculuklar</Text>
      </View>

      {/* Rides List Header */}
      <View style={styles.listHeaderRow}>
        <Text style={styles.sectionTitle}>Çevredeki Yolculuklar ({rides.length})</Text>
        <TouchableOpacity onPress={fetchRides}>
          <Text style={styles.refreshText}>🔄 Yenile</Text>
        </TouchableOpacity>
      </View>

      {loading ? (
        <ActivityIndicator size="large" color={colors.primary} style={{ marginTop: spacing.xl }} />
      ) : (
        <FlatList
          data={rides}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <Card style={styles.rideCard}>
              <View style={styles.driverRow}>
                <View style={styles.avatarCircle}>
                  <Text style={styles.avatarInitials}>
                    {item.sofor?.ad_soyad?.charAt(0) || 'Ş'}
                  </Text>
                </View>
                <View style={{ flex: 1, marginLeft: spacing.sm }}>
                  <Text style={styles.driverName}>{item.sofor?.ad_soyad}</Text>
                  <Badge level={item.sofor?.driver_points?.rozet_seviyesi || 'baslangic'} />
                </View>
                <View style={styles.capacityBadge}>
                  <Text style={styles.capacityText}>💺 {item.mevcut_kapasite} Boş Koltuk</Text>
                </View>
              </View>

              <View style={styles.routeBox}>
                <Text style={styles.routeText}>🟢 {item.baslangic_metni}</Text>
                <View style={styles.routeLine} />
                <Text style={styles.routeText}>🔴 {item.varis_metni}</Text>
              </View>

              <View style={styles.infoFooter}>
                <Text style={styles.timeText}>
                  🕒 Kalkış: {new Date(item.kalkis_zamani).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}
                </Text>
                <Text style={styles.vehicleText}>🚗 {item.vehicle?.marka_model} ({item.vehicle?.plaka})</Text>
              </View>

              <Button
                title={user?.is_premium ? '⭐ Öncelikli Biniş Talebi Gönder' : 'Biniş Talebi Gönder'}
                onPress={() => handleJoinRide(item.id)}
                loading={joiningRideId === item.id}
                style={{ marginTop: spacing.md }}
              />
            </Card>
          )}
          ListEmptyComponent={
            <View style={styles.emptyBox}>
              <Text style={styles.emptyTitle}>Yakınınızda aktif ilan bulunamadı 🔍</Text>
              <Text style={styles.emptySub}>Şoför moduna geçip ilk yolculuk ilanını siz oluşturabilirsiniz!</Text>
            </View>
          }
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: spacing.md,
  },
  topHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: spacing.md,
    marginTop: spacing.sm,
  },
  roleToggleBox: {
    flexDirection: 'row',
    backgroundColor: colors.surfaceLight,
    borderRadius: borderRadius.full,
    padding: 3,
  },
  roleBtn: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
  },
  roleBtnActive: {
    backgroundColor: colors.primary,
  },
  roleText: {
    color: colors.textMuted,
    fontWeight: '600',
    fontSize: fontSizes.xs,
  },
  roleTextActive: {
    color: '#FFF',
    fontWeight: '700',
    fontSize: fontSizes.xs,
  },
  premiumPill: {
    backgroundColor: colors.accent,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
  },
  premiumText: {
    color: '#000',
    fontWeight: '800',
    fontSize: fontSizes.xs,
  },
  mapCard: {
    backgroundColor: colors.surfaceLight,
    borderRadius: borderRadius.md,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.primary,
    marginBottom: spacing.md,
  },
  mapTitle: {
    color: colors.primary,
    fontWeight: '800',
    fontSize: fontSizes.md,
  },
  mapSub: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
  },
  listHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  sectionTitle: {
    color: colors.text,
    fontSize: fontSizes.md,
    fontWeight: '700',
  },
  refreshText: {
    color: colors.primary,
    fontSize: fontSizes.xs,
    fontWeight: '600',
  },
  rideCard: {
    padding: spacing.md,
  },
  driverRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  avatarCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.surfaceLight,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.primary,
  },
  avatarInitials: {
    color: colors.primary,
    fontWeight: 'bold',
    fontSize: fontSizes.md,
  },
  driverName: {
    color: colors.text,
    fontWeight: '700',
    fontSize: fontSizes.sm,
  },
  capacityBadge: {
    backgroundColor: 'rgba(16, 185, 129, 0.15)',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.sm,
  },
  capacityText: {
    color: colors.success,
    fontSize: fontSizes.xs,
    fontWeight: '700',
  },
  routeBox: {
    backgroundColor: colors.surfaceLight,
    padding: spacing.sm,
    borderRadius: borderRadius.sm,
    marginVertical: spacing.xs,
  },
  routeText: {
    color: colors.text,
    fontSize: fontSizes.xs,
    fontWeight: '600',
  },
  routeLine: {
    height: 1,
    backgroundColor: colors.border,
    marginVertical: spacing.xs,
  },
  infoFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.xs,
  },
  timeText: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
  },
  vehicleText: {
    color: colors.textMuted,
    fontSize: fontSizes.xs,
  },
  emptyBox: {
    alignItems: 'center',
    padding: spacing.xl,
  },
  emptyTitle: {
    color: colors.text,
    fontSize: fontSizes.md,
    fontWeight: '700',
  },
  emptySub: {
    color: colors.textMuted,
    fontSize: fontSizes.xs,
    textAlign: 'center',
    marginTop: spacing.xs,
  },
});
