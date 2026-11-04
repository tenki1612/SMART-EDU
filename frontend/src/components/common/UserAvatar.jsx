import React, { useState, useEffect } from 'react';

const roleGradients = {
  ADMIN: 'from-rose-500 to-pink-600 text-white',
  ACADEMIC_STAFF: 'from-purple-500 to-indigo-600 text-white',
  TEACHER: 'from-sky-500 to-blue-600 text-white',
  STUDENT: 'from-emerald-500 to-teal-600 text-white',
  PARENT: 'from-amber-500 to-orange-600 text-white',
  DEFAULT: 'from-indigo-500 to-purple-600 text-white',
};

const sizeClasses = {
  xs: 'w-6 h-6 text-[10px]',
  sm: 'w-8 h-8 text-xs',
  md: 'w-9 h-9 text-xs',
  lg: 'w-12 h-12 text-sm',
  xl: 'w-16 h-16 text-lg',
  '2xl': 'w-24 h-24 text-2xl',
};

export const normalizeImageUrl = (url) => {
  if (!url) return '';
  let trimmed = url.trim();
  if (!trimmed) return '';

  // Google Drive sharing link parser
  const gdriveMatch = trimmed.match(/drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)/);
  if (gdriveMatch && gdriveMatch[1]) {
    return `https://lh3.googleusercontent.com/d/${gdriveMatch[1]}`;
  }

  // Dropbox sharing link parser
  if (trimmed.includes('dropbox.com') && trimmed.includes('dl=0')) {
    return trimmed.replace('dl=0', 'raw=1');
  }

  // Prepend https:// if protocol is missing and not relative
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://') && !trimmed.startsWith('/')) {
    trimmed = `https://${trimmed}`;
  }

  return trimmed;
};

export const getResolvedAvatarUrl = (url) => {
  if (!url) return null;
  const normalized = normalizeImageUrl(url);
  if (!normalized) return null;
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return normalized;
  }
  // If relative path like /uploads/avatars/...
  return normalized.startsWith('/') ? normalized : `/${normalized}`;
};

export const UserAvatar = ({
  avatarUrl,
  name = '',
  role = 'DEFAULT',
  size = 'md',
  shape = 'rounded-xl',
  className = '',
  alt,
}) => {
  const [imgError, setImgError] = useState(false);
  const resolvedUrl = getResolvedAvatarUrl(avatarUrl);

  // Reset error state when avatarUrl changes
  useEffect(() => {
    setImgError(false);
  }, [avatarUrl]);

  const initial = name?.trim()?.charAt(0)?.toUpperCase() || 'U';
  const gradientClass = roleGradients[role] || roleGradients.DEFAULT;
  const sizeClass = sizeClasses[size] || sizeClasses.md;

  const hasValidImage = Boolean(resolvedUrl && !imgError);

  return (
    <div
      className={`relative inline-flex items-center justify-center shrink-0 overflow-hidden font-black select-none shadow-2xs ${sizeClass} ${shape} ${
        hasValidImage ? 'bg-slate-100 ring-1 ring-slate-200/60' : `bg-gradient-to-tr ${gradientClass}`
      } ${className}`}
    >
      {hasValidImage ? (
        <img
          src={resolvedUrl}
          alt={alt || name || 'Ảnh đại diện'}
          className="w-full h-full object-cover"
          referrerPolicy="no-referrer"
          onError={() => setImgError(true)}
          loading="lazy"
        />
      ) : (
        <span>{initial}</span>
      )}
    </div>
  );
};

