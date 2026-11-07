import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert, Image } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { Input } from '../../components/Input';
import { Button } from '../../components/Button';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const LoginScreen = ({ navigation }: any) => {
  const { login, isLoading } = useAuth();
  const [email, setEmail] = useState('caner.sofor@ogrenci.antalyabilim.edu.tr');
  const [password, setPassword] = useState('Password123!');

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Hata', 'Lütfen tüm alanları doldurunuz.');
      return;
    }

    try {
      await login(email, password);
    } catch (error: any) {
      Alert.alert('Giriş Başarısız', error.message || 'E-posta veya şifre hatalı.');
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <View style={styles.badgeBox}>
          <Text style={styles.logoText}>VERSITY</Text>
        </View>
        <Text style={styles.tagline}>Üniversiteliler İçin Güvenli Yol Paylaşımı</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>Hoş Geldiniz 🎓</Text>
        <Text style={styles.subtitle}>Okul e-postanız ve şifreniz ile giriş yapın</Text>

        <Input
          label="Okul E-postası (.edu.tr)"
          placeholder="ogrenci@universite.edu.tr"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <Input
          label="Uygulama Şifreniz"
          placeholder="••••••••"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />

        <Button title="Giriş Yap" onPress={handleLogin} loading={isLoading} style={{ marginTop: spacing.md }} />

        <TouchableOpacity onPress={() => navigation.navigate('Register')} style={styles.registerLink}>
          <Text style={styles.registerText}>
            Hesabınız yok mu? <Text style={{ color: colors.primary, fontWeight: '700' }}>Kayıt Olun</Text>
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    justifyContent: 'center',
    padding: spacing.lg,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  badgeBox: {
    backgroundColor: colors.surfaceLight,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.sm,
    borderRadius: borderRadius.lg,
    borderWidth: 1,
    borderColor: colors.primary,
  },
  logoText: {
    fontSize: fontSizes.title,
    fontWeight: '900',
    color: colors.primary,
    letterSpacing: 4,
  },
  tagline: {
    color: colors.textSecondary,
    fontSize: fontSizes.sm,
    marginTop: spacing.sm,
  },
  card: {
    backgroundColor: colors.cardGlass,
    borderRadius: borderRadius.lg,
    padding: spacing.xl,
    borderWidth: 1,
    borderColor: colors.border,
  },
  title: {
    fontSize: fontSizes.xl,
    fontWeight: '800',
    color: colors.text,
  },
  subtitle: {
    fontSize: fontSizes.sm,
    color: colors.textMuted,
    marginBottom: spacing.lg,
  },
  registerLink: {
    alignItems: 'center',
    marginTop: spacing.lg,
  },
  registerText: {
    color: colors.textSecondary,
    fontSize: fontSizes.sm,
  },
});
